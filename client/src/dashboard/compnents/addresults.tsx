import React, { useEffect, useState } from "react";
import "../../css/addresults.css";
import API_BASE_URL from "../../../config/ipconfig";
import axios from "axios";
import authService from "../../services/authService";

type User = {
  username: string;
  email: string;
  id: number;
};

interface Student {
  id: string;
  name: string;
  index: string;
}

function AddResultsPage() {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<string>("");

  // Search and select student
  const [searchUser, setSearchUser] = useState("");
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [showUserDropdown, setShowUserDropdown] = useState(false);

  // Student list
  const [students, setStudents] = useState<Student[]>([]);

  // Filtered students based on search
  const filteredStudents = students.filter((student) =>
    student.index.toLowerCase().includes(searchUser.toLowerCase())
  );

  // Load user and students
  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const userData = await authService.getUserData();
        setUser(userData);
      } catch (err: unknown) {
        if (err instanceof Error) setError(err.message);
        else setError("Unknown error fetching user data");
      }
    };

    const fetchStudents = async () => {
      try {
        const res = await axios.get(`${API_BASE_URL}/gusts`);
        const formatted = res.data.map((gust: any) => ({
          id: gust.gust_id,
          name: gust.name,
          index: gust.index,
        }));
        setStudents(formatted);
      } catch (err) {
        console.error("Error fetching students:", err);
      }
    };

    fetchUserData();
    fetchStudents();
  }, []);

  return (
    <div className="addresults-page">
      {error && <p className="error">{error}</p>}

      <div className="inputcontainer">
        <div className="label">Select Student Index</div>
        <div className="select-container" style={{ position: "relative" }}>
          <input
            type="text"
            className="input"
            placeholder="Type student index"
            value={searchUser}
            onChange={(e) => {
              setSearchUser(e.target.value);
              setShowUserDropdown(true);
            }}
            onFocus={() => setShowUserDropdown(true)}
          />

          {showUserDropdown && (
            <div className="dropdown">
              {filteredStudents.length > 0 ? (
                filteredStudents.map((student) => (
                  <div
                    key={student.id}
                    className="option"
                    onClick={() => {
                      setSearchUser(student.index); // show index in input
                      setShowUserDropdown(false);
                    }}
                    style={{
                      padding: "10px",
                      cursor: "pointer",
                      borderBottom: "1px solid #eee",
                    }}
                  >
                    {student.index} - {student.name} {/* show index + name */}
                  </div>
                ))
              ) : (
                <div style={{ padding: "10px" }}>No results</div>
              )}
            </div>
          )}
        </div>
      </div>
      {selectedUserId && <p>Selected Student ID: {selectedUserId}</p>}
    </div>
  );
}

export default AddResultsPage;
