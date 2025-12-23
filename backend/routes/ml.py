from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import pandas as pd
import joblib
import json
import requests
import os
from dotenv import load_dotenv

from database import get_db
from models import StudentProfile, StudentResult, Course
from schemas import MLRecommendationResponse

router = APIRouter()

# Load environment variables
load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
CX = os.getenv("GOOGLE_CSE_ID")

# Load ML model and feature columns
model = joblib.load("ml/course_recommendation_model.pkl")
with open("ml/feature_columns.json") as f:
    FEATURE_COLUMNS = json.load(f)


# --- Google Custom Search ---
def search_online_courses(query: str, num_results=5):
    url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "key": GOOGLE_API_KEY,
        "cx": CX,
        "q": query + " course",
        "num": num_results
    }
    response = requests.get(url, params=params)
    results = []
    if response.status_code == 200:
        data = response.json()
        for item in data.get("items", []):
            results.append({
                "course_name": item.get("title"),
                "url": item.get("link"),
                "snippet": item.get("snippet")
            })
    else:
        print("Google CSE Error:", response.status_code, response.text)
    return results


# --- Get student features ---
def get_student_features(user_id: str, db: Session):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    results = db.query(StudentResult).filter(StudentResult.user_id == user_id).all()
    if not profile or not results:
        return None

    marks = [float(r.marks) for r in results if r.marks]
    failed_count = sum(1 for r in results if r.grade == "F")
    failed_courses = [r.degree_id for r in results if r.grade == "F"]

    return {
        "degree_program": profile.degree_program,
        "current_year": profile.current_year,
        "avg_marks": sum(marks) / len(marks) if marks else 0,
        "failed_subject_count": failed_count,
        "career_goal": getattr(profile, "career_goal", None),
        "failed_courses": failed_courses
    }


# --- Prepare ML input ---
def prepare_ml_input(data: dict):
    ml_data = {k: v for k, v in data.items() if not isinstance(v, list)}
    df = pd.DataFrame([ml_data])
    df = pd.get_dummies(df)
    for col in FEATURE_COLUMNS:
        if col not in df.columns:
            df[col] = 0
    return df[FEATURE_COLUMNS]


# --- Main recommendation route ---
@router.get("/recommend/{user_id}", response_model=MLRecommendationResponse)
def recommend_course(user_id: str, db: Session = Depends(get_db)):

    # --- Step 1: Get student features ---
    features = get_student_features(user_id, db)
    if not features:
        payload = {
            "user_id": user_id,
            "relevance": 0,
            "confidence": 0.0,
            "recommended_courses": []
        }
        print("ML Recommendation Payload:\n", json.dumps(payload, indent=2))
        return MLRecommendationResponse(**payload)

    # --- Step 2: ML prediction ---
    X = prepare_ml_input(features)
    prediction = model.predict(X)[0]
    confidence = model.predict_proba(X)[0][1]

    # --- Step 3: Database courses ---
    all_courses = db.query(Course).all()
    recommended_courses = [{
        "course_id": course.course_id,
        "course_name": course.course_name,
        "category": course.category,
        "related_skills": course.related_skills
    } for course in all_courses]

    # --- Step 4: Always search online courses ---
    queries = []

    # Failed courses first
    for fc_id in features["failed_courses"]:
        course_obj = db.query(Course).filter(Course.course_id == fc_id).first()
        if course_obj:
            queries.append(course_obj.course_name)

    # If no failed courses, use career goal or degree program
    if not queries:
        queries.append(features.get("career_goal") or features.get("degree_program") or "programming")

    # Google search
    for q in queries:
        online_courses = search_online_courses(q)
        for oc in online_courses:
            if oc["course_name"] not in [c["course_name"] for c in recommended_courses]:
                recommended_courses.append(oc)

    # --- Step 5: Prepare payload ---
    payload = {
        "user_id": user_id,
        "relevance": 1 if recommended_courses else 0,
        "confidence": float(confidence),
        "recommended_courses": recommended_courses
    }

    # --- Step 6: Print payload to terminal ---
    print("ML Recommendation Payload:\n", json.dumps(payload, indent=2))

    # --- Step 7: Return response ---
    return MLRecommendationResponse(**payload)
