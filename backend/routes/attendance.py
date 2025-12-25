from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import pytz
from typing import List
from database import get_db
import models
from schemas import AttendanceCreate, AttendanceReport

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

# GET attendances by session_id
@router.get("/attendances/{session_id}")
def get_attendances(session_id: str, db: Session = Depends(get_db)):
    # Check if session exists
    session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Get all attendances for this session
    attendances = db.query(models.Attendance).filter(models.Attendance.session_id == session_id).all()

    # Return formatted response
    return [
        {
            "attendance_id": att.attendance_id,
            "student_id": att.student_id,
            "latitude": att.latitude,
            "longitude": att.longitude,
            "mark_at": att.mark_at.isoformat()
        } 
        for att in attendances
    ]

# GET attendances by student_id
@router.get("/attendance_info/{student_id}", response_model=List[dict])
def get_attendance_info(student_id: str, db: Session = Depends(get_db)):
    # Query Attendance, join with Sesstion and Course
    attendances = (
        db.query(models.Attendance)
        .join(models.Sesstion, models.Attendance.session_id == models.Sesstion.sessionid)
        .join(models.Course, models.Sesstion.module_id == models.Course.course_id)
        .filter(models.Attendance.student_id == student_id)
        .all()
    )

    if not attendances:
        raise HTTPException(status_code=404, detail="No attendance records found for this student.")

    result = []
    for att in attendances:
        session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == att.session_id).first()
        course = db.query(models.Course).filter(models.Course.course_id == session.module_id).first()
        result.append({
            "location_name": session.location_name,
            "course_name": course.course_name,
            "mark_at": att.mark_at,
            "latitude": att.latitude,    # for map button in frontend
            "longitude": att.longitude,  # for map button in frontend
        })
    
    return result

@router.get("/attendance/report", response_model=List[AttendanceReport])
def get_attendance_report(db: Session = Depends(get_db)):
    results = (
        db.query(
            models.Attendance.student_id,
            models.Attendance.mark_at,
            models.Attendance.latitude,
            models.Attendance.longitude,

            models.Sesstion.location_name,

            models.Course.course_name,
            models.Course.courseindex,
            models.Course.owner,

            models.Gust.name.label("student_name"),
            models.Gust.graduation_year
        )
        .join(models.Sesstion, models.Attendance.session_id == models.Sesstion.sessionid)
        .join(models.Course, models.Sesstion.module_id == models.Course.course_id)
        .join(models.Gust, models.Attendance.student_id == models.Gust.index)
        .order_by(models.Attendance.mark_at.desc())
        .all()
    )

    return results