from fastapi import APIRouter, HTTPException,Depends
from sqlalchemy.orm import Session
from database import get_db, SessionLocal
import models
import random
from schemas import AttendanceVerifyRequest, VerifyQrRequest
from fastapi_utils.tasks import repeat_every
from datetime import datetime, timedelta, timezone
router = APIRouter()

# -------------------------------
# Generate session token (initial)
# -------------------------------
@router.post("/session/{session_id}/generate_token")
def generate_token(session_id: int):
    db: Session = SessionLocal()
    try:
        session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == session_id).first()
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        token_entry = db.query(models.SessionToken).filter(
            models.SessionToken.session_id == session_id
        ).first()

        if not token_entry:
            # Create initial token
            token_value = f"SESSION-{session_id}"
            pin = random.randint(1000, 9999)
            expires_at = datetime.utcnow() + timedelta(hours=2)
            token_entry = models.SessionToken(
                session_id=session_id, token=token_value, pin=pin, expires_at=expires_at
            )
            db.add(token_entry)
            db.commit()
            db.refresh(token_entry)

        # Generate dynamic QR URL with session ID + PIN
        qr_url = f"https://yourdomain.com/attendance?session_id={session_id}&pin={token_entry.pin}"

        return {
            "token": token_entry.token,
            "pin": token_entry.pin,
            "qr_url": qr_url
        }

    finally:
        db.close()


# -------------------------------
# Get current PIN for frontend
# -------------------------------
@router.get("/session/{session_id}/get_pin")
def get_pin(session_id: int):
    db: Session = SessionLocal()
    try:
        token_entry = db.query(models.SessionToken).filter(models.SessionToken.session_id == session_id).first()

        if not token_entry:
            # Auto-create token if missing
            token_value = f"SESSION-{session_id}"
            pin = random.randint(1000, 9999)
            expires_at = datetime.utcnow() + timedelta(hours=2)
            token_entry = models.SessionToken(session_id=session_id, token=token_value, pin=pin, expires_at=expires_at)
            db.add(token_entry)
            db.commit()
            db.refresh(token_entry)

        return {"token": token_entry.token, "pin": token_entry.pin}
    finally:
        db.close()


# -------------------------------
# Verify attendance
# -------------------------------
# -------------------------------
# FINAL — Correct Verify Endpoint
# -------------------------------
@router.post("/attendance/verify")
def verify_attendance(data: AttendanceVerifyRequest, db: Session = Depends(get_db)):
    token_entry = db.query(models.SessionToken).filter(
        models.SessionToken.pin == data.pin
    ).first()

    if not token_entry:
        raise HTTPException(status_code=400, detail="Invalid PIN")

    if token_entry.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="PIN expired")

    # Return all available info
    return {
        "message": "Attendance verified successfully",
        "pin": token_entry.pin,
        "token": token_entry.token,
        "expires_at": token_entry.expires_at,
        "session_id": token_entry.session_id,
    }




# -------------------------------
# Background task: rotate PIN
# -------------------------------
@router.on_event("startup")
@repeat_every(seconds=90)
def rotate_pin_task():
    db: Session = SessionLocal()
    try:
        sessions = db.query(models.Sesstion).all()
        for s in sessions:
            token_entry = db.query(models.SessionToken).filter(
                models.SessionToken.session_id == s.sessionid
            ).first()

            if token_entry:
                token_entry.pin = random.randint(1000, 9999)

        db.commit()
    finally:
        db.close()


@router.post("/attendance/verify_qr")
def verify_attendance_qr(data: VerifyQrRequest, db: Session = Depends(get_db)):
    token_entry = db.query(models.SessionToken).filter(
        models.SessionToken.session_id == data.session_id,
        models.SessionToken.pin == data.pin
    ).first()

    if not token_entry:
        raise HTTPException(status_code=400, detail="Invalid session or PIN")

    if token_entry.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="PIN expired")

    return {
        "message": "Attendance verified successfully",
        "pin": token_entry.pin,
        "token": token_entry.token,
        "expires_at": token_entry.expires_at,
        "session_id": token_entry.session_id,
    }