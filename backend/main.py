import logging
from fastapi import FastAPI # type: ignore
from fastapi.middleware.cors import CORSMiddleware # type: ignore
from database import engine
import models

from routes import user,sesstion,token,course,gust,attendance,profile,results,location


logging.basicConfig(level=logging.INFO,format='%(asctime)s - %(levelname)s - %(message)s')
origins = ["*"]  # allow all origins

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# CORS settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# Include the user router
@app.get("/test")
async def test():
    return {"status": "ok"}

app.include_router(user.router)
app.include_router(sesstion.router)
app.include_router(token.router)
app.include_router(course.router)
app.include_router(gust.router)
app.include_router(attendance.router)
app.include_router(profile.router)
app.include_router(results.router)
app.include_router(location.router)


