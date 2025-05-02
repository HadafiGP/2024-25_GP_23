from flask import Flask, Response, json, request, jsonify
import pandas as pd
from dotenv import load_dotenv
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import firebase_admin
from firebase_admin import credentials, firestore, auth
import os
import numpy as np
import re

app = Flask(__name__)

# Initialize Firebase SDK
script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, "../.env")
# Handle env file path errors
if not os.path.exists(env_path):
    raise FileNotFoundError(f".env file not found at path: {env_path}")

load_dotenv(dotenv_path=env_path)


firebase_credentials_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
# Handle Firebase path errors
if not firebase_credentials_path:
    raise ValueError("Firebase credentials path is not set in the .env file.")

if not os.path.isabs(firebase_credentials_path):
    firebase_credentials_path = os.path.join(script_dir, firebase_credentials_path)

if not os.path.exists(firebase_credentials_path):
    raise FileNotFoundError(f"Firebase credentials file not found at path: {firebase_credentials_path}")

# Access Firestore database
cred = credentials.Certificate(firebase_credentials_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load COOP/internship opportunities dataset
dataset_name = "tempOpp.csv"
dataset_path = os.path.join(script_dir, dataset_name)

# Handle dataset errors
if not os.path.exists(dataset_path):
    raise FileNotFoundError(f"Dataset file not found at path: {dataset_path}")

opp_df = pd.read_csv(dataset_path, encoding='ISO-8859-1')



# Columns of interest for COOP/internship opportunities
job_columns = ['Company Descreption', 'Skills', 'Majors', 'Location', 'Job Title', 'Company Apply link', 'Company Name', 'GPA out of 5', 'GPA out of 4', ]


# Ensure each field is treated as a string
opp_df['GPA out of 5'] = pd.to_numeric(opp_df['GPA out of 5'], errors='coerce').fillna(0)
opp_df['GPA out of 4'] = pd.to_numeric(opp_df['GPA out of 4'], errors='coerce').fillna(0)

# Fill in missing values
for column in job_columns:
    opp_df[column] = opp_df[column].fillna('').astype(str)

# Preprocess Skills: Normalize, Deduplicate, Remove Special Characters
def preprocess_skills(skills):
    if not skills:
        return []
    skills = re.split(r'[,\n]', skills)  
    skills = [re.sub(r'[^a-zA-Z0-9 ]', '', skill.strip().lower()) for skill in skills]  
    return list(set(filter(None, skills)))  

opp_df['Skills'] = opp_df['Skills'].apply(preprocess_skills)
opp_df['Skills_Joined'] = opp_df['Skills'].apply(lambda x: ' '.join(x))  

# Initialize TF-IDF Vectorizer for Skills
tfidf_vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
tfidf_vectorizer.fit(opp_df['Skills_Joined'])
job_skill_vectors = tfidf_vectorizer.transform(opp_df['Skills_Joined'])

# Preprocess Locations: Handle alternate spellings (Jiddah)
opp_df['Location'] = opp_df['Location'].str.replace('Jiddah', 'Jeddah')
opp_df['Location'] = opp_df['Location'].apply(lambda x: set([loc.strip() for loc in x.split(',')]))

# Vectorize user data
def vectorize_user(user_data):
    all_user_skills =  user_data.get('skills') 
    all_user_skills = preprocess_skills(','.join(all_user_skills))  
    skills_combined = ' '.join(all_user_skills)
    user_skill_vector = tfidf_vectorizer.transform([skills_combined])
    return user_skill_vector






from flask import Response
import json

@app.route("/opportunities", methods=["GET"])
def get_all_opportunities():
    def generate():
        yield '{"opportunities": ['
        first = True
        for _, row in opp_df.iterrows():
            try:
                apply_url = row['Company Apply link']
                if not apply_url or not apply_url.strip():
                    apply_url = row.get('Job LinkedIn URL', '')

                # Ensure JSON serializable types only
                item = {
                    'Job Title': str(row.get('Job Title', '')),
                    'Description': str(row.get('Company Descreption', '')),
                    'Apply url': str(apply_url),
                    'Company Name': str(row.get('Company Name', 'N/A')),
                    'Locations': list(row.get('Location', set())),
                    'Skills': row.get('Skills', []),
                    'GPA out of 5': float(row.get('GPA out of 5', 0) or 0),
                    'GPA out of 4': float(row.get('GPA out of 4', 0) or 0),
                }

                json_string = json.dumps(item, ensure_ascii=False)

                if not first:
                    yield ','
                yield json_string
                first = False
            except Exception as e:
                print(f"Skipping bad row due to error: {e}")
                continue
        yield ']}'

    return Response(generate(), mimetype='application/json; charset=utf-8')






# Recommendation
@app.route("/recommend", methods=["POST"])
def recommend():
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Authorization header is missing or invalid"}), 401
        token = auth_header.split(" ")[1]
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token["uid"]

        # Get user data
        user_doc = db.collection("Student").document(user_id).get()
        if not user_doc.exists:
            return jsonify({"error": "The user's data is not found in the database"}), 404       
        user_data = user_doc.to_dict()

        # Validate required fields
        required_fields = ['major', 'location','skills']
        for field in required_fields:
            if field not in user_data or not user_data[field]:
                return jsonify({"error": f"Missing/empty field: {field}"}), 400


        user_locations = set(user_data['location'])

        # Vectorize user skills
        user_skill_vector = vectorize_user(user_data)

        # List of recommendations
        recommendations = []

        for i, row in opp_df.iterrows():
            # Filter by major
            if user_data['major'].lower() not in map(str.strip, row['Majors'].lower().split(',')):
                continue



            # Calculate skills similarity using cosine similarity
            job_skill_vector = job_skill_vectors[i]
            skills_similarity = cosine_similarity(user_skill_vector, job_skill_vector)[0][0]

            # If opportunity has no apply link, display the LinkedIn page URL instead
            apply_url = row['Company Apply link'] if pd.notna(row['Company Apply link']) and row['Company Apply link'].strip() else None
            if not apply_url: 
                apply_url = row.get('Job LinkedIn URL', '') 

            # Add recommendations to the recommendation list
            recommendations.append({
                'Job Title': row['Job Title'],
                'Description': row['Company Descreption'],
                'Apply url': apply_url,
                'Company Name': row.get('Company Name', 'N/A'),
                'Locations': list(row['Location']),
                'Skills': row['Skills'],
                'GPA out of 5': row['GPA out of 5'],
                'GPA out of 4': row['GPA out of 4'],
                'Skills Similarity': skills_similarity
            })

        # Sort recommendations by skills sim from highest to lowest
        recommendations = sorted(recommendations, key=lambda x: x['Skills Similarity'], reverse=True)
        return jsonify({"recommendations": recommendations})

    except ValueError as e:
        return jsonify({"error": f"An error occurred during user authorization: {str(e)}"}), 400

    except Exception as e:
        return jsonify({
            "error": "An unexpected error occurred while processing the recommendations.",
            "details": str(e)  
        }), 500


if __name__ == "__main__":
    app.run(debug=True)

