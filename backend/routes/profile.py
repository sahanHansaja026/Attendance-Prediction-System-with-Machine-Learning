import base64
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from database import get_db
from models import StudentProfile
from schemas import StudentProfileOut

router = APIRouter()


@router.put("/update/{user_id}", response_model=StudentProfileOut)
def update_student_profile(
    user_id: str,  
    full_name:Optional[str] = Form(None),
    degree_program: Optional[str] = Form(None),
    current_year: Optional[int] = Form(None),
    skills: Optional[str] = Form(None),
    career_goal: Optional[str] = Form(None),
    profileimage: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    if not profile:
        profile = StudentProfile(user_id=user_id)
        db.add(profile)

    # Update fields only if provided
    if full_name is not None:
        profile.full_name = full_name
    if degree_program is not None:
        profile.degree_program = degree_program
    if current_year is not None:
        profile.current_year = current_year
    if skills is not None:
        profile.skills = skills
    if career_goal is not None:
        profile.career_goal = career_goal
    if profileimage is not None:
        profile.profileimage = profileimage.file.read()

    db.commit()
    db.refresh(profile)

    return profile

@router.get("/profile/{user_id}", response_model=StudentProfileOut)
def get_profile(user_id: str, db: Session = Depends(get_db)):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.get("/profilewith/{user_id}", response_model=StudentProfileOut)
def get_profile(user_id: str, db: Session = Depends(get_db)):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    profile_dict = profile.__dict__.copy()
    if profile.profileimage:
        profile_dict['profileimage'] = base64.b64encode(profile.profileimage).decode('utf-8')
    else:
        profile_dict['profileimage'] = None

    return profile_dict
