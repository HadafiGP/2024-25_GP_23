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

# Initialize Firebase SDK
script_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(script_dir, "../.env")
if not os.path.exists(env_path):
    raise FileNotFoundError(f".env file is not found at: {env_path}")
load_dotenv(dotenv_path=env_path)


# Handle firebase path errors
firebase_credentials_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
if not firebase_credentials_path:
    raise ValueError("Firebase credentials path is not found in .env file.")

if not os.path.isabs(firebase_credentials_path):
    firebase_credentials_path = os.path.join(script_dir, firebase_credentials_path)

if not os.path.exists(firebase_credentials_path):
    raise FileNotFoundError(f"Firebase credentials file is not found at: {firebase_credentials_path}")


# Access Firestore database
cred = credentials.Certificate(firebase_credentials_path)
firebase_admin.initialize_app(cred)

db = firestore.client()
print("Firebase access is successful")

# Load COOP/internship opportunities data
dataset_name = "ClayWebScrapingwithskills20NOV 4.csv"
dataset_path = os.path.join(script_dir, dataset_name)

# Handle dataset path errors
if not os.path.exists(dataset_path):
    raise FileNotFoundError(f"Dataset file not found at path: {dataset_path}")

try:
    opp_df = pd.read_csv(dataset_path)
    print(f"Dataset loaded successfully with {len(opp_df)} rows.")
except Exception as e:
    raise ValueError(f"Error loading dataset: {str(e)}")

# Columns of interest for COOP/internship opportunities
opp_columns = ['Company Descreption', 'Skills', 'Majors', 'Location', 'GPA out of 5', 'GPA out of 4', 'Job Title', 'Company Apply link']
for column in opp_columns:
    opp_df[column] = opp_df[column].fillna('').astype(str)

# Ensure each field is treated as a string
opp_df['GPA out of 5'] = pd.to_numeric(opp_df['GPA out of 5'], errors='coerce').fillna(0)
opp_df['GPA out of 4'] = pd.to_numeric(opp_df['GPA out of 4'], errors='coerce').fillna(0)


# Split the list and remove whitespaces in location list
opp_df['Location'] = opp_df['Location'].apply(
    lambda x: [loc.strip() for loc in x.split(',')] if x else []
)


# Clean the dskills and remove whitespaces and lower the skills charcters
opp_df['Skills'] = opp_df['Skills'].apply(
    lambda x: list(set([skill.strip().lower() for skill in x.split(',')])) if x else []
)


# Initialize lists for selection fields (for encoding consistency)
cities = [
    'Abha', 'Al Ahsa', 'Al Khobar', 'Al Qassim', 'Dammam', 'Hail', 'Jeddah', 'Jizan', 'Jubail',
    'Mecca', 'Medina', 'Najran', 'Riyadh', 'Tabuk', 'Taif'
]

# Function to expand "Saudi Arabia" to all cities
def expand_saudi_arabia(locations):
    if 'Saudi Arabia' in locations:
        return cities # Replace "Saudi Arabia" with the list of all cities if mentioned in Location 
    return locations

# Standardize any alternate spellings (Jiddah/Saudi Arabia)
opp_df['Location'] = opp_df['Location'].apply(lambda x: ['Jeddah' if loc == 'Jiddah' else loc for loc in x])
opp_df['Location'] = opp_df['Location'].apply(expand_saudi_arabia)

# location binarizer
location_binarizer = MultiLabelBinarizer()
location_binarizer.fit(opp_df['Location'])

# MultiLabelBinarizer for skill
skills_binarizer = MultiLabelBinarizer()
skills_binarizer.fit(opp_df['Skills'])  

opp_skill_vectors = csr_matrix(skills_binarizer.transform(opp_df['Skills']))

# StandrsScaler for GPA
gpa_scaler = StandardScaler()
gpa_scaler.fit(opp_df[['GPA out of 5', 'GPA out of 4']])

# vectorize opportunities function:
# 1. Binary Skills
# 2. GPA Scaling
# 3. Binary Location 
def vectorize_opp():
    try:
        opp_skill_vectors = csr_matrix(skills_binarizer.transform(opp_df['Skills']))
    except Exception as e:
        print(f"Error vectorizing opportunity skills: {e}")
        opp_skill_vectors = csr_matrix(np.zeros((len(opp_df), len(skills_binarizer.classes_))))

    try:
        opp_gpa_vectors = csr_matrix(gpa_scaler.transform(opp_df[['GPA out of 5', 'GPA out of 4']]))
    except Exception as e:
        print(f"Error vectorizing opportunity GPA: {e}")
        opp_gpa_vectors = csr_matrix(np.zeros((len(opp_df), 2)))

    try:
        opp_location_vectors = csr_matrix(location_binarizer.transform(opp_df['Location']))
    except Exception as e:
        print(f"Error vectorizing opportunity location: {e}")
        opp_location_vectors = csr_matrix(np.zeros((len(opp_df), len(location_binarizer.classes_))))

    return opp_skill_vectors, opp_gpa_vectors, opp_location_vectors


# Call vectorize opportunities and store results
opp_skill_vectors, opp_gpa_vectors, opp_location_vectors = vectorize_opp()

# Vectorize user function:(ensure same processing as opp for unfication and calculation)
# 1. Binary Skills
# 2. GPA Scaling
# 3. Binary Location 
def vectorize_user(user_data):

    try:
        user_data['skills'] = list(set([skill.strip().lower() for skill in user_data['skills']]))

    except Exception as e:
        print(f"Error cleaning user skills: {e}")
        user_data['skills'] = []

    try:
        user_skill_vector = csr_matrix(skills_binarizer.transform([user_data['skills']]))
    except Exception as e:
        print(f"Error vectorizing user skills: {e}")
        user_skill_vector = csr_matrix(np.zeros((1, len(skills_binarizer.classes_))))

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

    return user_skill_vector, user_gpa_vector, user_location_vector


#Calculate GPA similarity:
#1.If student GPA equal or more than required GPA score=1
#2.If student GPA less than GPA score is: the difference
#3.If GPA is not required score=1
def calculate_gpa_similarity(user_gpa, user_gpa_scale, opp_gpa_5, opp_gpa_4):
    try:
        user_gpa = float(user_gpa)
        user_gpa_scale = float(user_gpa_scale)

        if opp_gpa_5 == 0 and opp_gpa_4 == 0:
            return 1.0

        if user_gpa_scale == 5:
            user_gpa_scaled = user_gpa
        elif user_gpa_scale == 4:
            user_gpa_scaled = user_gpa * (5 / 4)
        else:
            return 0.0  # if not 5/4 GPA scales

        opp_gpa = max(opp_gpa_5, opp_gpa_4 * (5 / 4))

        if user_gpa_scaled >= opp_gpa:
            return 1.0

        return 1 - abs(user_gpa_scaled - opp_gpa) / 5
    except Exception as e:
        print(f"Error calculating GPA similarity: {e}")
        return 0.0


#Calculate skills similarity:
#1. If student skills is aligned and he's overqualified (more skills than required) score=1
#2. If student skills is aligned completly (no overqualification) score=1
#3. If student skills somewhat aligned(no overqualification)=calculate intersection(the required skills)
#4. If no similairty at all score =0
def calculate_skills_similarity(user_skills_vector, opp_skills_vector):
    try:
        intersection = user_skills_vector.multiply(opp_skills_vector).sum()
        required_skills_count = opp_skills_vector.sum()
        user_skills_count = user_skills_vector.sum()

        if required_skills_count == 0:  
            return 1.0  

        if intersection == required_skills_count:  
            if user_skills_count > required_skills_count: 
                return 1.0 
            return 1.0  

        if intersection == 0: 
            return 0.0

        similarity = intersection / required_skills_count 
        return similarity
    except Exception as e:
        print(f"Error calculating skills similarity: {e}")
        return 0.0


#If student location prefernces align with only one of the opportunity location socre=1, otherwise score=0 
# (Student is satsifed with any alignment)
def calculate_location_similarity(user_locations, opp_locations):
    try:
        user_locations_list = user_locations.toarray().flatten()
        opp_locations_list = opp_locations.toarray().flatten()
        if np.dot(user_locations_list, opp_locations_list) > 0:
            return 1.0
        return 0.0
    except Exception as e:
        print(f"Error calculating location similarity: {e}")
        return 0.0


#Retreive data and vectorize and calculate total similairty(Weights assigned based on importance)
# then return it so it's handled and printed in the app
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

        user_skill_vector, user_gpa_vector, user_location_vector = vectorize_user(user_data)
        recommendations = []

        for i, row in opp_df.iterrows():
            if user_data['major'].lower() in map(str.strip, row['Majors'].lower().split(',')):

                opp_skill_vector = opp_skill_vectors[i]
                opp_gpa_vector = opp_gpa_vectors[i]
                opp_location_vector = opp_location_vectors[i]


                skills_similarity = calculate_skills_similarity(user_skill_vector, opp_skill_vector)
                location_similarity = calculate_location_similarity(user_location_vector, csr_matrix(opp_location_vector))
                gpa_similarity = calculate_gpa_similarity(
                    user_gpa=user_data['gpa'],
                    user_gpa_scale=user_data['gpaScale'],
                    opp_gpa_5=row['GPA out of 5'],
                    opp_gpa_4=row['GPA out of 4']
                )

                total_similarity = 0.34 * skills_similarity + 0.33 * location_similarity + 0.33 * gpa_similarity

                # If opportunity has no apply link, display the LinkedIn page URL instead
                apply_url = row['Company Apply link'] if pd.notna(row['Company Apply link']) and row['Company Apply link'].strip() else None
                if not apply_url: 
                    apply_url = row.get('Job LinkedIn URL', '') 

                recommendations.append({
                    'Job Title': row['Job Title'],
                    'Description': row['Company Descreption'],
                    'Apply url': apply_url,
                    'Company Name': row.get('Company Name', 'N/A'),
                    'Skills': row['Skills'],
                    'Locations': row['Location'],
                    'GPA out of 5': row['GPA out of 5'],
                    'GPA out of 4': row['GPA out of 4'],
                    'Total Similarity': total_similarity
                })
                print(row['Job Title'], skills_similarity, location_similarity, gpa_similarity, total_similarity)
        
        recommendations = sorted(recommendations, key=lambda x: x['Total Similarity'], reverse=True)
        return jsonify({"recommendations": recommendations})

    except Exception as e:
        return jsonify({"error in generation recommendation:": str(e)}), 500
if __name__ == "__main__":
    app.run(debug=True)
