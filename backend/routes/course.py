from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import get_db
import models, schemas

router = APIRouter()

# Get all courses
@router.get("/courses", response_model=List[schemas.CourseResponse])
def get_courses(db: Session = Depends(get_db)):
    courses = db.query(models.Course).all()
    return courses

# Optional: Get course by ID
@router.get("/courses/{course_id}", response_model=schemas.CourseResponse)
def get_course(course_id: int, db: Session = Depends(get_db)):
    course = db.query(models.Course).filter(models.Course.course_id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    return course

@router.post("/courses", response_model=schemas.CourseResponse, status_code=201)
def create_course(course: schemas.CourseCreate, db: Session = Depends(get_db)):
    new_course = models.Course(
        course_name=course.course_name,
        credits=course.credits,
        courseindex=course.courseindex,
        owner=course.owner,
        category=course.category,
        related_skills=course.related_skills
    )

    db.add(new_course)
    db.commit()
    db.refresh(new_course)

    return new_course