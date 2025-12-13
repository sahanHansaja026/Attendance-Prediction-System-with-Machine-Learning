import React from 'react';
import "../../css/buttons.css";

interface ButtonPageProps {
    setActivePage1: (page: string) => void;
}

function ButtonPage({ setActivePage1 }: ButtonPageProps) {
    return (
        <div className='button'>
            <button
                className='addbtn'
                onClick={() => setActivePage1("addcourses")}
            >
                + Add Course
            </button>

            <button
                className='addbtn'
                onClick={() => setActivePage1("adduser")}
            >
                + Add User
            </button>

            <button
                className='addbtn'
                onClick={() => setActivePage1("showuser")}
            >
                View Users
            </button>

            <button
                className='addbtn'
                onClick={() => setActivePage1("sessionqr")}
            >
                Mark Attendance
            </button>

            <button
                className='addbtn'
                onClick={() => setActivePage1("attendaceshow")}
            >
                Show Attendance
            </button>

            <button
                className='addbtn'
                onClick={() => setActivePage1("analysis")}
            >
                Analytics
            </button>
        </div>
    );
}

export default ButtonPage;
