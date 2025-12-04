import email
from enum import unique
from database import Base
from sqlalchemy import Column, Numeric, Integer, String, ForeignKey, DateTime
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
    
    sessionid = Column(Integer, primary_key=True, index=True)  # renamed from sesstionid
    userid = Column(Integer, ForeignKey("users.id"), nullable=False)
    module_name = Column(String, nullable=False)
    location_name = Column(String, nullable=False)
    start_time = Column(String, nullable=False)
    end_time = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(pytz.timezone("Asia/Colombo")))

    user = relationship("User", back_populates="sessions")
    tokens = relationship("SessionToken", back_populates="session") # optional reverse relationship:

class SessionToken(Base):
    __tablename__ = "session_tokens"

    token_id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sesstion.sessionid"), nullable=False)
    token = Column(String, nullable=False)   # not unique, changes every 60s
    pin = Column(Integer, nullable=False)
    expires_at = Column(DateTime, nullable=False)  # track expiry

    session = relationship("Sesstion", back_populates="tokens")
    
class Course(Base):
    __tablename__="courses"
    
    course_id = Column(Integer, primary_key=True, index=True)
    course_name= Column(String,nullable=False)
    courseindex=Column(String,nullable=False)
    owner=Column(Integer, nullable=False)

class Gust(Base):
    __tablename__="gusts"
    
    gust_id=Column(Integer, primary_key=True, index=True)
    name=Column(String,nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    index=Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    graduation_year = Column(Integer, nullable=False)   
    
