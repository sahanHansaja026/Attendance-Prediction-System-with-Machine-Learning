import React from 'react';
import "../../css/usercreate.css";

interface ShowUsersProps {
  setActivePage: (page: string) => void;   // <-- FIX
}

function ShowUsers({ setActivePage }: ShowUsersProps) {

  return (
    <div className='createuser'>
      <div className='buttoncontainer'>
        <button
          className='addbtn'
          onClick={() => setActivePage("adduser")}
        >
          + Add New User
        </button>
      </div>
    </div>
  );
}

export default ShowUsers;
