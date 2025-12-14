import React from 'react';
import "../../css/buttons.css";

interface ButtonPageProps {
    setActivePage1: (page: string) => void;
}

function ButtonPage({ setActivePage1 }: ButtonPageProps) {
    return (
        <div className='button'>
            <div className='buttoncontainer'>
                <button
                    className='addbtn'
                    onClick={() => setActivePage1("addcourses")}
                >
                    + Add Course
                </button>

                <button
                    className='addbtn'
                    onClick={() => setActivePage1("addresults")}
                >
                    + Results
                </button>
            </div>
        </div>
    );
}

export default ButtonPage;
