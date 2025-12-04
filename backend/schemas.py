from pydantic import BaseModel, EmailStr, Field,constr # type: ignore
from typing import Optional
from datetime import datetime
from datetime import date
import pytz


class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email:EmailStr
    password:str
    
class UserUpdate(BaseModel):
    username: Optional[str] = None
    level: Optional[str] = None
    exam_date: Optional[date] = None
    about: Optional[str] = None
    profile_image: Optional[bytes] = None
    
class UserOut(BaseModel):
    id: int
    username: str
    email: EmailStr
    level: str
    exam_date: date
    about: Optional[str] = None

    class Config:
        orm_mode = True

# Session Schemas
# -----------------------------
# Input schema
class SesstionCreate(BaseModel):
    userid: int
    module_name: str
    location_name: str
    start_time: str
    end_time: str

# Response schema
class SesstionResponse(BaseModel):
    sessionid: int
    userid: int
    module_name: str
    location_name: str
    start_time: str
    end_time: str
    created_at: datetime

    class Config:
        from_attributes = True

    def dict(self, *args, **kwargs):
        data = super().dict(*args, **kwargs)
        local_tz = pytz.timezone("Asia/Colombo")
        data["created_at"] = data["created_at"].astimezone(local_tz)
        return data

class CourseResponse(BaseModel):
    course_id: int
    course_name: str
    courseindex: str
    owner: int

    class Config:
        orm_mode = True

class GustCreate(BaseModel):
    name: str
    email: EmailStr
    index: str
    password: str
    graduation_year: int


class GustResponse(BaseModel):
    gust_id: int
    name: str
    email: EmailStr
    index: str
    graduation_year: int

    class Config:
        orm_mode = True

class GustLogin(BaseModel):
    email: str
    password: str
