import email
from enum import unique
from database import Base
from sqlalchemy import Column, Numeric, Integer, String, ForeignKey, DateTime, UniqueConstraint, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
import pytz


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    
    sessions = relationship("Sesstion", back_populates="user")


class Sesstion(Base):
    __tablename__ = "sesstion"
    
    sessionid = Column(Integer, primary_key=True, index=True)
    userid = Column(Integer, ForeignKey("users.id"), nullable=False)   
    module_id = Column(Integer, nullable=False)
    location_name = Column(String, nullable=False)
    start_time = Column(String, nullable=False)
    end_time = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(pytz.timezone("Asia/Colombo")))

    user = relationship("User", back_populates="sessions")
    attendances = relationship("Attendance", back_populates="session")
    tokens = relationship("SessionToken", back_populates="session")


class SessionToken(Base):
    __tablename__ = "session_tokens"

    token_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sesstion.sessionid"), nullable=False)
    token = Column(String, nullable=False)
    pin = Column(Integer, nullable=False)
    expires_at = Column(DateTime, nullable=False)

    session = relationship("Sesstion", back_populates="tokens")

class Course(Base):
    __tablename__="courses"
    
    course_id = Column(Integer, primary_key=True, index=True)
    course_name = Column(String, nullable=False)
    credits = Column(Integer, nullable=False)           
    courseindex = Column(String, nullable=False,unique=True)
    owner = Column(String, nullable=False)
    category = Column(String, nullable=True)
    related_skills = Column(String, nullable=True)

    results = relationship("StudentResult", back_populates="course")



class Gust(Base):
    __tablename__="gusts"
    
    gust_id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    index = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    graduation_year = Column(Integer, nullable=False)   
    refresh_token = Column(String, nullable=True)


    student_profile = relationship("StudentProfile", back_populates="student", uselist=False)
    results = relationship("StudentResult", back_populates="student")
    recommendations = relationship("Recommendation", back_populates="student")
    attendances = relationship("Attendance", back_populates="student")



class Attendance(Base):
    __tablename__ = "attendance"
    
    attendance_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sesstion.sessionid"), nullable=False)
    student_id = Column(Integer, ForeignKey("gusts.gust_id"), nullable=False)
    latitude = Column(String, nullable=False)
    longitude = Column(String, nullable=False)
    mark_at = Column(DateTime(timezone=True), default=lambda: datetime.now(pytz.timezone("Asia/Colombo")))

    session = relationship("Sesstion", back_populates="attendances")
    student = relationship("Gust", back_populates="attendances")


class StudentProfile(Base):
    __tablename__ = "student_profiles"

    profile_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("gusts.gust_id"), unique=True, nullable=False)
    degree_program = Column(String, nullable=False)
    current_year = Column(Integer, nullable=False)
    cgpa = Column(Numeric(3,2), nullable=True)
    skills = Column(String, nullable=True)
    career_goal = Column(String, nullable=True)

    student = relationship("Gust", back_populates="student_profile")

class StudentResult(Base):
    __tablename__ = "student_results"

    result_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("gusts.gust_id"), nullable=False)
    course_id = Column(Integer, ForeignKey("courses.course_id"), nullable=False)
    grade = Column(String, nullable=True)
    marks = Column(Integer, nullable=True)
    completed = Column(Boolean, default=True)

    student = relationship("Gust", back_populates="results")
    course = relationship("Course", back_populates="results")

class Recommendation(Base):
    __tablename__ = "recommendations"

    rec_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("gusts.gust_id"), nullable=False)
    recommended_modules = Column(String, nullable=False)
    generated_at = Column(DateTime, default=datetime.utcnow)

    student = relationship("Gust", back_populates="recommendations")

class KnowledgeBase(Base):
    __tablename__ = "knowledge_base"

    knowledge_id = Column(Integer, primary_key=True, index=True)
    category = Column(String, nullable=False)
    content = Column(String, nullable=False)
    source = Column(String, nullable=True)
