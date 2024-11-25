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

# Initialize Firebase Admin SDK
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

# Access Firestore database
db = firestore.client()
print("Firebase Admin initialized successfully!")

# Load job opportunities data
dataset_name = "ClayWebScrapingwithskills20NOV 4.csv"
dataset_path = os.path.join(script_dir, dataset_name)

if not os.path.exists(dataset_path):
    raise FileNotFoundError(f"Dataset file not found at path: {dataset_path}")

try:
    opp_df = pd.read_csv(dataset_path)
    print(f"Dataset loaded successfully with {len(opp_df)} rows.")
except Exception as e:
    raise ValueError(f"Error loading dataset: {str(e)}")

# Columns of interest for job opportunities
job_columns = ['Company Descreption', 'Skills', 'Majors', 'Location', 'GPA out of 5', 'GPA out of 4', 'Job Title', 'Company Apply link']
for column in job_columns:
    opp_df[column] = opp_df[column].fillna('').astype(str)

# Ensure each field is treated as a string
opp_df['GPA out of 5'] = pd.to_numeric(opp_df['GPA out of 5'], errors='coerce').fillna(0)
opp_df['GPA out of 4'] = pd.to_numeric(opp_df['GPA out of 4'], errors='coerce').fillna(0)


# Split the list and remove whitespaces
opp_df['Location'] = opp_df['Location'].apply(
    lambda x: [loc.strip() for loc in x.split(',')] if x else []
)

#split the skills list and lower the letters
opp_df['Skills'] = opp_df['Skills'].apply(
    lambda x: list(set([skill.strip().lower() for skill in x.split(',')])) if x else []
)


print("Sample processed data:")
print(opp_df[['Skills', 'Location']].head())


# Initialize lists for selection fields (for encoding consistency)
cities = [
    'Abha', 'Al Ahsa', 'Al Khobar', 'Al Qassim', 'Dammam', 'Hail', 'Jeddah', 'Jizan', 'Jubail',
    'Mecca', 'Medina', 'Najran', 'Riyadh', 'Tabuk', 'Taif'
]

# Function to expand "Saudi Arabia" to all cities
def expand_saudi_arabia(locations):
    if 'Saudi Arabia' in locations:
        return cities # Replace "Saudi Arabia" with the list of all cities 
    return locations

# Standardize any alternate spellings
opp_df['Location'] = opp_df['Location'].apply(lambda x: ['Jeddah' if loc == 'Jiddah' else loc for loc in x])
opp_df['Location'] = opp_df['Location'].apply(expand_saudi_arabia)

# Initialize location binarizer
location_binarizer = MultiLabelBinarizer()
location_binarizer.fit(opp_df['Location'])

#Initalize StandardScaler for GPA
tfidf_vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
tfidf_vectorizer.fit([' '.join(skills) for skills in opp_df['Skills']])

#Initialize StandrsScaler for GPA
gpa_scaler = StandardScaler()
gpa_scaler.fit(opp_df[['GPA out of 5', 'GPA out of 4']])

# Modular function to vectorize opportunities
def vectorize_opp():
    try:
        opp_text_vectors = tfidf_vectorizer.transform([' '.join(skills) for skills in opp_df['Skills']])
    except Exception as e:
        print(f"Error vectorizing job skills: {e}")
        opp_text_vectors = csr_matrix(np.zeros((len(opp_df), tfidf_vectorizer.max_features)))

    try:
        opp_gpa_vectors = csr_matrix(gpa_scaler.transform(opp_df[['GPA out of 5', 'GPA out of 4']]))
    except Exception as e:
        print(f"Error vectorizing job GPA: {e}")
        opp_gpa_vectors = csr_matrix(np.zeros((len(opp_df), 2)))

    try:
        opp_location_vectors = csr_matrix(location_binarizer.transform(opp_df['Location']))
    except Exception as e:
        print(f"Error vectorizing job location: {e}")
        opp_location_vectors = csr_matrix(np.zeros((len(opp_df), len(location_binarizer.classes_))))

    return opp_text_vectors, opp_gpa_vectors, opp_location_vectors


# Call vectorize_opportunities and store results
opp_text_vectors, opp_gpa_vectors, opp_location_vectors = vectorize_opp()

# Modular function to vectorize a user
def vectorize_user(user_data):
    try:
        skills_combined = ' '.join(skill.lower() for skill in user_data['skills'])
        user_text_vector = tfidf_vectorizer.transform([skills_combined])
    except Exception as e:
        print(f"Error vectorizing user skills: {e}")
        user_text_vector = csr_matrix(np.zeros((1, tfidf_vectorizer.max_features)))

    try:
        user_gpa_df = pd.DataFrame(
            [[float(user_data['gpa']), float(user_data['gpaScale'])]],
            columns=['GPA out of 5', 'GPA out of 4']
        )
        user_gpa_vector = csr_matrix(gpa_scaler.transform(user_gpa_df))
    except Exception as e:
        print(f"Error vectorizing user GPA: {e}")
        user_gpa_vector = csr_matrix(np.zeros((1, 2)))

    try:
        user_location_vector = csr_matrix(location_binarizer.transform([user_data['location']]))
    except Exception as e:
        print(f"Error vectorizing user location: {e}")
        user_location_vector = csr_matrix(np.zeros((1, len(location_binarizer.classes_))))

    return user_text_vector, user_gpa_vector, user_location_vector


#Calculate GPA similarity:
#1.If student GPA equal or more than required GPA score=1
#2.If student GPA less than GPA score is: the difference
#3.If GPA is not required score=1
def calculate_gpa_similarity(user_gpa, user_gpa_scale, job_gpa_5, job_gpa_4):
    try:
        user_gpa = float(user_gpa)
        user_gpa_scale = float(user_gpa_scale)

        if job_gpa_5 == 0 and job_gpa_4 == 0:
            return 1.0

        if user_gpa_scale == 5:
            user_gpa_scaled = user_gpa
        elif user_gpa_scale == 4:
            user_gpa_scaled = user_gpa * (5 / 4)
        else:
            return 0.0  # Unsupported GPA scale

        job_gpa = max(job_gpa_5, job_gpa_4 * (5 / 4))

        if user_gpa_scaled >= job_gpa:
            return 1.0

        return 1 - abs(user_gpa_scaled - job_gpa) / 5
    except Exception as e:
        print(f"Error calculating GPA similarity: {e}")
        return 0.0


#Calculate skills similarity:
#1. If student skills is aligned and he's overqualified (more skills than required) score=1
#2. If student skills is aligned completly score=1
#3. If student skills somewhat aligned=calculte cosine similarity
#4. If no similairt at all score =0
def calculate_skills_similarity(user_skills_vector, job_skills_vector):
    try:
        relevant_user_vector = user_skills_vector.multiply(job_skills_vector > 0)
        return cosine_similarity(relevant_user_vector, job_skills_vector)[0][0]
    except Exception as e:
        print(f"Error calculating skills similarity: {e}")
        return 0.0


#If student location prefernces align with only one of the opportunity location socre=1, otherwise score=0 
# (Student is satsifed with any alignment)
def calculate_location_similarity(user_locations, job_locations):
    try:
        user_locations_array = user_locations.toarray().flatten()
        job_locations_array = job_locations.toarray().flatten()
        if np.dot(user_locations_array, job_locations_array) > 0:
            return 1.0
        return 0.0
    except Exception as e:
        print(f"Error calculating location similarity: {e}")
        return 0.0


#Retreive data and vectorize and calculate similairty, and return it so it's handled and printed in the app
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
                    'GPA out of 5': row['GPA out of 5'],
                    'GPA out of 4': row['GPA out of 4'],
                    'Total Similarity': total_similarity
                })
        

        recommendations = sorted(recommendations, key=lambda x: x['Total Similarity'], reverse=True)
        return jsonify({"recommendations": recommendations})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
