from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from datetime import datetime
import pytz  # pip install pytz

router = APIRouter()

local_tz = pytz.timezone("Asia/Colombo")

@router.post("/create_session", response_model=schemas.SesstionResponse)
def create_session(session: schemas.SesstionCreate, db: Session = Depends(get_db)):
    new_session = models.Sesstion(
        userid=session.userid,
        module_id=session.module_id,
        location_name=session.location_name,
        start_time=session.start_time,
        end_time=session.end_time,
        created_at=datetime.now(local_tz)  # local timezone timestamp
    )
    db.add(new_session)
    db.commit()
    db.refresh(new_session)

    # 🔹 Print the session to terminal for debugging
    print("Created Session:", {
        "sessionid": new_session.sessionid,
        "userid": new_session.userid,
        "module_id": new_session.module_id,
        "location_name": new_session.location_name,
        "start_time": new_session.start_time,
        "end_time": new_session.end_time,
        "created_at": new_session.created_at
    })

    return new_session

@router.delete("/delete_session/{session_id}")
def delete_session(session_id: int, db: Session = Depends(get_db)):
    session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Delete related attendance records
    db.query(models.Attendance).filter(models.Attendance.session_id == session_id).delete()

    # Delete related session tokens
    db.query(models.SessionToken).filter(models.SessionToken.session_id == session_id).delete()

    # Delete the session itself
    db.delete(session)
    db.commit()
    
    return {"message": "Session deleted successfully", "deleted_session_id": session_id}



# get session by session_id
@router.get("/get_session/{session_id}")
def get_session(session_id: int, db: Session = Depends(get_db)):
    session = db.query(models.Sesstion).filter(models.Sesstion.sessionid == session_id).first()
    
    if not session:
        print(f"Session {session_id} not found")  # Log not found
        return {"error": "Session not found"}

    payload = {
        "sessionid": session.sessionid,
        "module_id": session.module_id,
        "module_name": session.course.course_name if session.course else "",
        "location_name": session.location_name,
        "start_time": session.start_time,
        "end_time": session.end_time,
        "created_at": session.created_at.isoformat() if session.created_at else "",
    }

    print("Session Payload:", payload)  # <-- This prints payload in terminal

    return payload
