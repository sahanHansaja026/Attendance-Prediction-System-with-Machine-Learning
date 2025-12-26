# Attendance Management System with Location Tracking

## Overview

This project is a **full-stack attendance management system** enabling educators to **track attendance with location verification**.  

Key components include:  

- **React Vite web frontend** for administration  
- **Flutter mobile app** for teachers and students  
- **FastAPI backend** with PostgreSQL  
- **Machine learning analytics** for predictive insights  
- **Dockerized deployment** for scalable operations  

---

## Features

- **Attendance Tracking**: Mark and view attendance with geolocation.  
- **Multi-platform Access**: Web (React Vite) and mobile (Flutter).  
- **User Management**: Administer students and teachers.  
- **Modules & Courses**: Add and view course modules.  
- **Analytics Dashboard**: Graphical view of attendance trends.  
- **Machine Learning Insights**: Predict attendance patterns and analyze feature importance.  
- **Docker Deployment**: Independent containers for frontend and backend.  
- **Reliable Database**: PostgreSQL stores all relevant data securely.  

---

## Architecture

- **Frontend**: Admin dashboard and course management interface  
- **Backend**: FastAPI REST API handling attendance, authentication, and ML predictions  
- **Database**: PostgreSQL for persistent storage  
- **ML Component**: Random Forest model generating predictive insights  

---

## Visual Analytics

The system includes a **feature importance graph** derived from our ML model, showing which factors most influence student attendance:

![Attendance Feature Importance](./docs/feature_importance.png)

> This graph helps educators make **data-driven decisions** by visualizing the relative impact of different features.

---

## Docker Deployment

- **Frontend (React Vite)** and **Backend (FastAPI)** run in separate Docker containers for modularity and scalability.  
- Optionally, a **docker-compose setup** can launch the entire stack (frontend, backend, PostgreSQL, and ML service) with a single command.  

---

## Flutter Mobile App

- Students and teachers can mark and view attendance.  
- Geolocation ensures accurate attendance tracking.  
- Connects seamlessly with the FastAPI backend via REST API.  

---

## Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/attendance-system.git
cd attendance-system
````
Run Backend
```bash
docker build -t attendance-backend ./server
docker run -p 8000:8000 attendance-backend
````


Run Frontend
```bash
docker build -t attendance-frontend ./client
docker run -p 5173:5173 attendance-frontend
```

Flutter App

Open mobile_app folder in Android Studio or VS Code.

Configure backend API URL and run on device or emulator.

Technologies Used

Frontend: React, Vite, TypeScript, CSS

Mobile App: Flutter, Dart

Backend: FastAPI, Python, SQLAlchemy

Database: PostgreSQL

Machine Learning: scikit-learn, matplotlib, numpy

Containerization: Docker

Future Improvements

Real-time notifications for attendance

Advanced ML predictions for student performance

Role-based access control

Push notifications in Flutter app

Author

Madawala Maddumage Sahan Hansaja
Email: sahanhansaja026@gmail.com


✅ Notes on this version:  
- The **feature importance graph** is highlighted visually without showing any ML code.  
- The README looks **more professional and concise**.  
- Docker instructions are summarized, leaving a note for a future `docker-compose` setup.  
- Visual appeal is improved for non-technical readers (like educators).  

If you want, I can **also redesign the README visually with badges, GIFs for mobile UI, and color-coded sections** to make it **even more creative and eye-catching** for GitHub.  

Do you want me to do that next?

