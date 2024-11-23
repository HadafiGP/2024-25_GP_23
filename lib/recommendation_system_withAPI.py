from flask import Flask, request, jsonify
import pandas as pd
from dotenv import load_dotenv
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import MultiLabelBinarizer, StandardScaler
from scipy.sparse import csr_matrix
from sklearn.metrics.pairwise import cosine_similarity
import firebase_admin
from firebase_admin import credentials, firestore, auth
import numpy as np
import os

app = Flask(__name__)


script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, "../.env")
if not os.path.exists(env_path):
    raise FileNotFoundError(f".env file not found at path: {env_path}")
load_dotenv(dotenv_path=env_path)


firebase_credentials_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
if not firebase_credentials_path:
    raise ValueError("Firebase credentials path is not set in the .env file.")

if not os.path.isabs(firebase_credentials_path):
    firebase_credentials_path = os.path.join(script_dir, firebase_credentials_path)

if not os.path.exists(firebase_credentials_path):
    raise FileNotFoundError(f"Firebase credentials file not found at path: {firebase_credentials_path}")

cred = credentials.Certificate(firebase_credentials_path)
firebase_admin.initialize_app(cred)
db = firestore.client()
print("Firebase Admin initialized successfully!")


dataset_name = "ClayWebScrapingwithskills20NOV 4.csv"
dataset_path = os.path.join(script_dir, dataset_name)

if not os.path.exists(dataset_path):
    raise FileNotFoundError(f"Dataset file not found at path: {dataset_path}")

try:
    opp_df = pd.read_csv(dataset_path)
    print(f"Dataset loaded successfully with {len(opp_df)} rows.")
except Exception as e:
    raise ValueError(f"Error loading dataset: {str(e)}")


job_columns = ['Company Descreption', 'Skills', 'Majors', 'Location', 'GPA out of 5', 'GPA out of 4', 'Job Title', 'Company Apply link']
for column in job_columns:
    opp_df[column] = opp_df[column].fillna('').astype(str)

opp_df['GPA out of 5'] = pd.to_numeric(opp_df['GPA out of 5'], errors='coerce').fillna(0)
opp_df['GPA out of 4'] = pd.to_numeric(opp_df['GPA out of 4'], errors='coerce').fillna(0)

opp_df['Location'] = opp_df['Location'].apply(lambda x: x.split(',') if x else [])
opp_df['Skills'] = opp_df['Skills'].apply(
    lambda x: list(set([skill.strip().lower() for skill in x.split(',')])) if x else []
)
print("Sample processed data:")
print(opp_df[['Skills', 'Location']].head())

opp_df['Location'] = opp_df['Location'].apply(lambda x: ['Jeddah' if loc == 'Jiddah' else loc for loc in x])

location_binarizer = MultiLabelBinarizer()
location_binarizer.fit(opp_df['Location'])

tfidf_vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
tfidf_vectorizer.fit([' '.join(skills) for skills in opp_df['Skills']])

gpa_scaler = StandardScaler()
gpa_scaler.fit(opp_df[['GPA out of 5', 'GPA out of 4']])

def vectorize_opp():
    opp_text_vectors = tfidf_vectorizer.transform([' '.join(skills) for skills in opp_df['Skills']])
    opp_gpa_vectors = csr_matrix(gpa_scaler.transform(opp_df[['GPA out of 5', 'GPA out of 4']]))
    opp_location_vectors = csr_matrix(location_binarizer.transform(opp_df['Location']))
    return opp_text_vectors, opp_gpa_vectors, opp_location_vectors

opp_text_vectors, opp_gpa_vectors, opp_location_vectors = vectorize_opp()

def vectorize_user(user_data):
    skills_combined = ' '.join(skill.lower() for skill in user_data['skills'])
    user_text_vector = tfidf_vectorizer.transform([skills_combined])

    user_gpa_df = pd.DataFrame(
        [[float(user_data['gpa']), float(user_data['gpaScale'])]],
        columns=['GPA out of 5', 'GPA out of 4']
    )
    user_gpa_vector = csr_matrix(gpa_scaler.transform(user_gpa_df))

    user_location_vector = csr_matrix(location_binarizer.transform([user_data['location']]))

    return user_text_vector, user_gpa_vector, user_location_vector

def calculate_gpa_similarity(user_gpa, user_gpa_scale, job_gpa_5, job_gpa_4):
    try:
        user_gpa = float(user_gpa)
        user_gpa_scale = float(user_gpa_scale)
    except ValueError:
        raise ValueError("GPA and GPA scale must be numeric values.")

    if job_gpa_5 == 0 and job_gpa_4 == 0:
        return 1.0

    if user_gpa_scale == 5:
        user_gpa_scaled = user_gpa
    elif user_gpa_scale == 4:
        user_gpa_scaled = user_gpa * (5 / 4)
    else:
        raise ValueError("Unsupported GPA scale. Only 4 or 5 are allowed.")

    job_gpa = max(job_gpa_5, job_gpa_4 * (5 / 4))

    if user_gpa_scaled >= job_gpa:
        return 1.0

    return 1 - abs(user_gpa_scaled - job_gpa) / 5

def calculate_skills_similarity(user_skills_vector, job_skills_vector):
    return cosine_similarity(user_skills_vector, job_skills_vector)[0][0]

def calculate_location_similarity(user_locations, job_locations):
    user_locations_array = user_locations.toarray().flatten()
    job_locations_array = job_locations.toarray().flatten()
    if np.dot(user_locations_array, job_locations_array) > 0:
        return 1.0
    return 0.0

@app.route("/recommend", methods=["POST"])
def recommend():
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return jsonify({"error": "Authorization header is missing or invalid"}), 401
    try:
        token = auth_header.split(" ")[1]
        decoded_token = auth.verify_id_token(token)
        user_id = decoded_token["uid"]
    except Exception as e:
        return jsonify({"error": f"Invalid or expired token: {str(e)}"}), 401

    user_doc = db.collection("Student").document(user_id).get()
    if not user_doc.exists:
        return jsonify({"error": "User data not found"}), 404
    user_data = user_doc.to_dict()

    required_fields = ['skills', 'gpa', 'gpaScale', 'location', 'major']
    for field in required_fields:
        if field not in user_data:
            return jsonify({"error": f"Missing required field: {field}"}), 400

    if not isinstance(user_data['skills'], list) or not all(isinstance(skill, str) for skill in user_data['skills']):
        return jsonify({"error": "Skills must be an array of strings"}), 400

    try:
        user_text_vector, user_gpa_vector, user_location_vector = vectorize_user(user_data)
        recommendations = []

        for i, row in opp_df.iterrows():
            if user_data['major'].lower() in map(str.strip, row['Majors'].lower().split(',')):
                job_text_vector = opp_text_vectors[i]
                job_gpa_vector = opp_gpa_vectors[i]
                job_location_vector = opp_location_vectors[i]

                skills_similarity = calculate_skills_similarity(user_text_vector, job_text_vector)
                location_similarity = calculate_location_similarity(user_location_vector, csr_matrix(job_location_vector))
                gpa_similarity = calculate_gpa_similarity(
                    user_gpa=user_data['gpa'],
                    user_gpa_scale=user_data['gpaScale'],
                    job_gpa_5=row['GPA out of 5'],
                    job_gpa_4=row['GPA out of 4']
                )

                total_similarity = 0.34 * skills_similarity + 0.33 * location_similarity + 0.33 * gpa_similarity
                recommendations.append({
                    'Job Title': row['Job Title'],
                    'Description': row['Company Descreption'],
                    'Apply url': row['Company Apply link'],
                    'Company Name': row.get('Company Name', 'N/A'),
                    'Skills': row['Skills'],
                    'Locations': row['Location'],
                    'Total Similarity': total_similarity
                })

        recommendations = sorted(recommendations, key=lambda x: x['Total Similarity'], reverse=True)
        return jsonify({"recommendations": recommendations})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
