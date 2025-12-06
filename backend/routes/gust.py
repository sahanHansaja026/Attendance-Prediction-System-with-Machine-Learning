from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from typing import List
from auth import hash_password ,veryfy_password # 🔥 Use your existing hashing
from fastapi import Body
from gustauth import create_access_token, create_refresh_token

router = APIRouter()

@router.post("/add_gust", response_model=schemas.GustResponse)
def add_gust(gust: schemas.GustCreate, db: Session = Depends(get_db)):

    # Check duplicate email
    existing_email = db.query(models.Gust).filter(models.Gust.email == gust.email).first()
    if existing_email:
        raise HTTPException(status_code=400, detail="Email already exists")

    # Check duplicate index
    existing_index = db.query(models.Gust).filter(models.Gust.index == gust.index).first()
    if existing_index:
        raise HTTPException(status_code=400, detail="Index number already exists")

    # Hash password using your project's method
    hashed_pass = hash_password(gust.password)

    new_gust = models.Gust(
        name=gust.name,
        email=gust.email,
        index=gust.index,
        hashed_password=hashed_pass,
        graduation_year=gust.graduation_year
    )

    db.add(new_gust)
    db.commit()
    db.refresh(new_gust)

    return new_gust

@router.post("/gust_login")
def gust_login(data: schemas.GustLogin, db: Session = Depends(get_db)):
    email = data.email
    password = data.password

    gust = db.query(models.Gust).filter(models.Gust.email == email).first()

    if not gust:
        raise HTTPException(status_code=404, detail="User not found")

    if not veryfy_password(password, gust.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect password")

    access_token = create_access_token({"sub": gust.email})
    refresh_token = create_refresh_token({"sub": gust.email})

    gust.refresh_token = refresh_token
    db.commit()

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": {
            "name": gust.name,
            "email": gust.email,
            "index": gust.index
        }
    }

@router.get("/gusts", response_model=List[schemas.GustResponse])
def get_all_gusts(db: Session = Depends(get_db)):
    gusts = db.query(models.Gust).all()
    return [
        schemas.GustResponse(
            gust_id=g.gust_id,
            name=g.name,
            email=g.email,
            index=g.index,
            graduation_year=g.graduation_year
        ) for g in gusts
    ]
    
@router.post("/gust_logout")
def gust_logout(token_data: schemas.TokenData = Body(...), db: Session = Depends(get_db)):
    email = token_data.email.strip()
    gust = db.query(models.Gust).filter(models.Gust.email == email).first()
    if not gust:
        raise HTTPException(status_code=404, detail="User not found")

    gust.refresh_token = None
    db.commit()
    return {"message": "Logout successful"}




