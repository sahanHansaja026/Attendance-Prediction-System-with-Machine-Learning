import React from 'react';
import "../../css/buttons.css";

interface ButtonPageProps {
    setActivePage1: (page: string) => void;
}

function ShowButtonPage({ setActivePage1 }: ButtonPageProps) {
    return (
        <div className='button'>
            <div className='buttoncontainer'>

                <button
                    className='addbtn'
                    onClick={() => setActivePage1("showuser")}
                >
                    View Users
                </button>

                <button
                    className='addbtn'
                    onClick={() => setActivePage1("showcourses")}
                >
                    View Course
                </button>
            </div>
            <div className='buttoncontainer'>
                <button
                    className='addbtn'
                    onClick={() => setActivePage1("addresults")}
                >
                    + Results
                </button>

                <button
                    className='addbtn'
                    onClick={() => setActivePage1("showlocation")}
                >
                    View Locations
                </button>
            </div>
        </div>
    );
}

export default ShowButtonPage;
