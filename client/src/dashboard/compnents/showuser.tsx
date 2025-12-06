import React, { useEffect, useState } from 'react';
import axios from 'axios';
import "../../css/usercreate.css";
import API_BASE_URL from '../../../config/ipconfig';

interface ShowUsersProps {
  setActivePage: (page: string) => void;
}

interface User {
  gust_id: number;
  name: string;
  email: string;
  index: string;
  graduation_year: number;
}

function ShowUsers({ setActivePage }: ShowUsersProps) {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    // Fetch users from backend
    axios.get<User[]>(`${API_BASE_URL}/gusts`)
      .then((response) => {
        setUsers(response.data);
        setLoading(false);
      })
      .catch((error) => {
        console.error("Error fetching users:", error);
        setLoading(false);
      });
  }, []);

  // Filter users based on searchTerm
  const filteredUsers = users.filter((user) =>
    user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.index.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className='createuser'>
      <div className='displaybtncontainer '>
        <div className='buttoncontainer'>
          <button
            className='addbtn'
            onClick={() => setActivePage("adduser")}
          >
            + Add New User
          </button>
        </div>
        <input
          type="text"
          placeholder="Search by Name, Email, or Index"
          className="search-input"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>
      {loading ? (
        <p>Loading users...</p>
      ) : (
        <table className="user-table">
          <thead>
            <tr>
              <th>Number</th>
              <th>Index Number</th>
              <th>Name</th>
              <th>Email</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.length > 0 ? (
              filteredUsers.map((user, index) => (
                <tr key={user.gust_id}>
                  <td>{index + 1}</td>
                  <td>{user.index}</td>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={4} style={{ textAlign: "center" }}>
                  No users found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default ShowUsers;
