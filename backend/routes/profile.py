from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from database import get_db
from models import StudentProfile
from schemas import StudentProfileOut

router = APIRouter()

@router.put("/update/{user_id}", response_model=StudentProfileOut)
def update_student_profile(
    user_id: int,  
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
