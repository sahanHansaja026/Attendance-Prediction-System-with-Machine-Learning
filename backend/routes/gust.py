from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas
from auth import hash_password  # 🔥 Use your existing hashing

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
