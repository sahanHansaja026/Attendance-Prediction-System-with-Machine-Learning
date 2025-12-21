from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from models import LocationsBase
from schemas import LocationCreate
from database import get_db

router = APIRouter()


@router.post("/locationinsert", status_code=201)
def create_location(
    location: LocationCreate,
    db: Session = Depends(get_db)
):
    new_location = LocationsBase(
        name=location.name,
        latitude=str(location.latitude),   # convert if DB uses String
        longitude=str(location.longitude)
    )

    db.add(new_location)
    db.commit()
    db.refresh(new_location)

    return new_location
