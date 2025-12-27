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

interface Course {
  id: string;
  name: string;
}

interface ResultRow {
  module: string;
  moduleId: string;
  marks: string;
  grade: string;
}

function AddResultsPage() {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState("");

  /* ---------------- STUDENT ---------------- */
  const [students, setStudents] = useState<Student[]>([]);
  const [searchUser, setSearchUser] = useState("");
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [showUserDropdown, setShowUserDropdown] = useState(false);

  const filteredStudents = students.filter((s) =>
    s.index.toLowerCase().includes(searchUser.toLowerCase())
  );

  /* ---------------- COURSES ---------------- */
  const [courses, setCourses] = useState<Course[]>([]);

  /* ---------------- GRADES ---------------- */
  const GradeList = [
    "A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-",
    "D+", "D", "D-", "E", "-"
  ];

  /* ---------------- RESULTS ---------------- */
  const [results, setResults] = useState<ResultRow[]>([
    { module: "", moduleId: "", marks: "", grade: "" }
  ]);

  const [showModuleDropdown, setShowModuleDropdown] = useState<boolean[]>([false]);
  const [showGradeDropdown, setShowGradeDropdown] = useState<boolean[]>([false]);

  /* ---------------- LOAD DATA ---------------- */
  useEffect(() => {
    const loadData = async () => {
      try {
        setUser(await authService.getUserData());

        const studentRes = await axios.get(`${API_BASE_URL}/gusts`);
        setStudents(
          studentRes.data.map((g: any) => ({
            id: g.gust_id,
            name: g.name,
            index: g.index,
          }))
        );

        const courseRes = await axios.get(`${API_BASE_URL}/courses`);
        setCourses(
          courseRes.data.map((c: any) => ({
            id: c.course_id,
            name: c.course_name,
          }))
        );
      } catch (err: any) {
        setError(err.message || "Error loading data");
      }
    };

    loadData();
  }, []);

  /* ---------------- HELPERS ---------------- */
  const addAnotherResult = () => {
    setResults([...results, { module: "", moduleId: "", marks: "", grade: "" }]);
    setShowModuleDropdown([...showModuleDropdown, false]);
    setShowGradeDropdown([...showGradeDropdown, false]);
  };

  const updateResult = (index: number, field: keyof ResultRow, value: string) => {
    const updated = [...results];
    updated[index][field] = value;
    setResults(updated);
  };

  const submitResults = async () => {
    if (!selectedUserId) {
      setError("Please select a student");
      return;
    }

    try {
      await Promise.all(
        results
          .filter(r => r.moduleId)
          .map(r =>
            axios.post(`${API_BASE_URL}/student-results`, {
              user_id: selectedUserId,
              degree_id: Number(r.moduleId),
              marks: r.marks || null,
              grade: r.grade || null,
              completed: true,
            })
          )
      );

      alert("Results added successfully ✅");

      setResults([{ module: "", moduleId: "", marks: "", grade: "" }]);
      setShowModuleDropdown([false]);
      setShowGradeDropdown([false]);
      setSearchUser("");
      setSelectedUserId(null);
    } catch (err: any) {
      console.error(err.response?.data || err);
      setError("Failed to submit results");
    }
  };

  return (
    <div className="addresults-page">
      {error && <p className="error">{error}</p>}

      {/* STUDENT SELECT */}
      <div className="inputcontainer">
        <div className="label">Type Student Index</div>
        <div className="select-container">
          <input
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
              {filteredStudents.map((s) => (
                <div
                  key={s.id}
                  className="option"
                  onClick={() => {
                    setSearchUser(s.index);
                    setSelectedUserId(s.index);
                    setShowUserDropdown(false);
                  }}
                >
                  {s.index} - {s.name}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {selectedUserId && <p>Selected Student ID: {selectedUserId}</p>}

      {/* RESULT ROWS */}
      {results.map((row, i) => {
        const filteredModules = courses.filter((c) =>
          c.name.toLowerCase().includes(row.module.toLowerCase())
        );
        const filteredGrades = GradeList.filter((g) =>
          g.toLowerCase().includes(row.grade.toLowerCase())
        );

        return (
          <div className="flexinsert" key={i}>
            {/* MODULE */}
            <div className="inputcontainer2">
              <div className="label">Module Name</div>
              <div className="select-container">
                <input
                  className="input"
                  placeholder="Type module name"
                  value={row.module}
                  onChange={(e) => {
                    updateResult(i, "module", e.target.value);
                    const temp = [...showModuleDropdown];
                    temp[i] = true;
                    setShowModuleDropdown(temp);
                  }}
                />
                {showModuleDropdown[i] && filteredModules.length > 0 && (
                  <div className="dropdown">
                    {filteredModules.map((c) => (
                      <div
                        key={c.id}
                        className="option"
                        onClick={() => {
                          updateResult(i, "module", c.name);
                          updateResult(i, "moduleId", c.id.toString());
                          const temp = [...showModuleDropdown];
                          temp[i] = false;
                          setShowModuleDropdown(temp);
                        }}
                      >
                        {c.name}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* MARKS */}
            <div className="inputcontainer2">
              <div className="label">CA Marks</div>
              <input
                className="input"
                value={row.marks}
                onChange={(e) =>
                  updateResult(i, "marks", e.target.value)
                }
              />
            </div>

            {/* GRADE */}
            <div className="inputcontainer2">
              <div className="label">Final Grade</div>
              <div className="select-container">
                <input
                  className="input"
                  placeholder="Select grade"
                  value={row.grade}
                  onChange={(e) => {
                    updateResult(i, "grade", e.target.value);
                    const temp = [...showGradeDropdown];
                    temp[i] = true;
                    setShowGradeDropdown(temp);
                  }}
                />
                {showGradeDropdown[i] && filteredGrades.length > 0 && (
                  <div className="dropdown">
                    {filteredGrades.map((g) => (
                      <div
                        key={g}
                        className="option"
                        onClick={() => {
                          updateResult(i, "grade", g);
                          const temp = [...showGradeDropdown];
                          temp[i] = false;
                          setShowGradeDropdown(temp);
                        }}
                      >
                        {g}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        );
      })}

      <button className="button" onClick={addAnotherResult}>
        Add Another Result
      </button>
      <button className="button primary" onClick={submitResults}>
        Submit Results
      </button>
    </div>
  );
}

export default AddResultsPage;
