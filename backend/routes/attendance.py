from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import pytz

from database import get_db
import models
from schemas import AttendanceCreate

router = APIRouter()

@router.post("/mark_attendance")
def mark_attendance(request: AttendanceCreate, db: Session = Depends(get_db)):
    # Check if session exists
    session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == request.session_id).first()
    if not session:
        raise HTTPException(status_code=400, detail="Invalid session ID")

    # Check if this student already marked attendance for this session
    existing = db.query(models.Attendance).filter(
        models.Attendance.session_id == request.session_id,
        models.Attendance.student_id == request.student_id
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Attendance already marked for this session")

    # Create new attendance
    new_attendance = models.Attendance(
        session_id=request.session_id,
        student_id=request.student_id,
        latitude=request.latitude,
        longitude=request.longitude,
        mark_at=datetime.now(pytz.timezone("Asia/Colombo"))  # automatically set
    )

    db.add(new_attendance)
    db.commit()
    db.refresh(new_attendance)

    return {
        "message": "Attendance marked successfully",
        "attendance_id": new_attendance.attendance_id,
        "mark_at": new_attendance.mark_at.isoformat()
    }
