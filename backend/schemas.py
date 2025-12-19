from pydantic import BaseModel, EmailStr, Field,constr 
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

class SesstionCreate(BaseModel):
    userid: int
    module_id: int
    location_name: str
    start_time: str
    end_time: str

class SesstionResponse(BaseModel):
    sessionid: int
    userid: int
    module_id: int
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
    owner: str

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

class TokenData(BaseModel):
    email: str

class AttendanceVerifyRequest(BaseModel):
    pin: int

class AttendanceCreate(BaseModel):
    session_id: int
    student_id: str
    latitude: str
    longitude: str

    class Config:
        from_attributes = True

class CourseBase(BaseModel):
    course_name: str
    credits: int
    courseindex: str
    owner: str
    category: Optional[str] = None
    related_skills: Optional[str] = None


class CourseCreate(CourseBase):
    pass

class StudentProfileBase(BaseModel):
    degree_program: Optional[str] = None
    current_year: Optional[int] = None
    skills: Optional[str] = None 
    career_goal: Optional[str] = None
    full_name:Optional[str]= None

class StudentProfileUpdate(StudentProfileBase):
    pass

class StudentProfileOut(StudentProfileBase):
    user_id: str
    profileimage: Optional[str] = None 

    class Config:
        orm_mode = True
        
class StudentResultCreate(BaseModel):
    user_id: str
    degree_id: int
    grade: Optional[str] = None
    marks: Optional[str] = None   # ✔ STRING
    completed: Optional[bool] = True


class StudentResultResponse(StudentResultCreate):
    result_id: int

    class Config:
        from_attributes = True
