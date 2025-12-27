import React, { useEffect, useState } from 'react';
import axios from 'axios';
import "../../css/usercreate.css";
import API_BASE_URL from '../../../config/ipconfig';

interface ShowCourseProps {
    setActivePage: (page: string) => void;
}

interface User {
    course_id: number;
    course_name: string;
    credits: number;
    owner: string;
    courseindex: string;
}

function ShowCoursesPage({ setActivePage }: ShowCourseProps) {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {
        // Fetch users from backend
        axios.get<User[]>(`${API_BASE_URL}/courses`)
            .then((response) => {
                setUsers(response.data);
                setLoading(false);
            })
            .catch((error) => {
                console.error("Error fetching Courses:", error);
                setLoading(false);
            });
    }, []);

    // Filter users based on searchTerm
    const filteredUsers = users.filter((user) =>
        user.course_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.courseindex.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.owner.toLowerCase().includes(searchTerm.toLowerCase())

    );

    return (
        <div className='createuser'>
            <div className='displaybtncontainer '>
                <input
                    type="text"
                    placeholder="Search by Name, or module code"
                    className="search-input"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </div>
            {loading ? (
                <p>Loading modules...</p>
            ) : (
                <table className="user-table">
                    <thead>
                        <tr>
                            <th>Number</th>
                            <th>MOdule Code</th>
                            <th>Module Name</th>
                            <th>Credit</th>
                            <th>owner</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filteredUsers.length > 0 ? (
                            filteredUsers.map((user, index) => (
                                <tr key={user.course_id}>
                                    <td>{index + 1}</td>
                                    <td>{user.courseindex}</td>
                                    <td>{user.course_name}</td>
                                    <td>{user.credits}</td>
                                    <td>{user.owner}</td>
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

export default ShowCoursesPage;
