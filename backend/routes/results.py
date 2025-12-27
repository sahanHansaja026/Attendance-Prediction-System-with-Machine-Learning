from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
import models
import schemas

router = APIRouter()

@router.post("/student-results", response_model=schemas.StudentResultResponse, status_code=201)
def create_student_result(
    result: schemas.StudentResultCreate,
    db: Session = Depends(get_db)
):
    new_result = models.StudentResult(
        user_id=result.user_id,
        degree_id=result.degree_id,
        grade=result.grade,
        marks=result.marks,
        completed=result.completed
    )

    db.add(new_result)
    db.commit()
    db.refresh(new_result)

    return new_result

from typing import List

@router.get(
    "/student-results/{user_id}",
    response_model=List[schemas.StudentResultResponseuser]
)
def get_results_by_user_id(
    user_id: str,
    db: Session = Depends(get_db)
):
    # Join StudentResult with Course using degree_id foreign key
    results = (
        db.query(
            models.StudentResult.result_id,
            models.StudentResult.user_id,
            models.StudentResult.grade,
            models.StudentResult.marks,
            models.StudentResult.completed,
            models.Course.course_name   # <-- Use the correct class name
        )
        .join(models.Course, models.StudentResult.degree_id == models.Course.course_id)
        .filter(models.StudentResult.user_id == user_id)
        .all()
    )

    # Convert to list of dictionaries
    return [
        {
            "result_id": r.result_id,
            "user_id": r.user_id,
            "grade": r.grade,
            "marks": r.marks,
            "completed": r.completed,
            "course_name": r.course_name,
        }
        for r in results
    ]
