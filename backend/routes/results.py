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
