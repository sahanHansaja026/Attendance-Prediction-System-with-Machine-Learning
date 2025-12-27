import React, { useState, useEffect } from "react";
import "../../css/create.css";
import authService from "../../services/authService";
import axios from "axios";
import API_BASE_URL from "../../../config/ipconfig"; // your backend base URL

type User = {
    username: string;
    email: string;
    id: number;
};

interface Course {
    id: string;
    name: string;
}

interface ShowUsersProps {
    setActivePage: (page: string) => void;
}

function Create_Sesstion({ setActivePage }: ShowUsersProps) {
    const [user, setUser] = useState<User | null>(null);
    const [error, setError] = useState<string>("");

    // TIME
    const [startHour, setStartHour] = useState("");
    const [startMinute, setStartMinute] = useState("");
    const [startPeriod, setStartPeriod] = useState("am");

    const [endHour, setEndHour] = useState("");
    const [endMinute, setEndMinute] = useState("");
    const [endPeriod, setEndPeriod] = useState("am");

    // MODULE SELECT
    const [searchModule, setSearchModule] = useState("");
    const [selectedCourseId, setSelectedCourseId] = useState<string | null>(null);
    const [showModuleDropdown, setShowModuleDropdown] = useState(false);

    // LOCATION SELECT
    const [searchLocation, setSearchLocation] = useState("");
    const [showLocationDropdown, setShowLocationDropdown] = useState(false);

    // COURSES LIST
    const [courses, setCourses] = useState<Course[]>([]);

    // LOCATION LIST
    const locationList = ["Hall A", "Hall B", "Hall C", "Lab 1", "Lab 2", "Lab 3"];
    const filteredLocations = locationList.filter((loc) =>
        loc.toLowerCase().includes(searchLocation.toLowerCase())
    );

    // FILTER MODULES
    const filteredModules = courses.filter((course) =>
        course.name.toLowerCase().includes(searchModule.toLowerCase())
    );

    // LOAD USER AND COURSES
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

        const fetchCourses = async () => {
            try {
                const res = await axios.get(`${API_BASE_URL}/courses`);

                const formatted = res.data.map((course: any) => ({
                    id: course.course_id,
                    name: course.course_name
                }));

                setCourses(formatted);
            } catch (err) {
                console.error("Error fetching courses:", err);
            }
        };

        fetchUserData();
        fetchCourses();
    }, []);

    // TIME CONVERTER
    const convertTo24Hour = (hour: string, minute: string, period: string) => {
        let h = parseInt(hour);
        if (period === "pm" && h !== 12) h += 12;
        if (period === "am" && h === 12) h = 0;
        return `${h.toString().padStart(2, "0")}:${minute.padStart(2, "0")}:00`;
    };
    

    // SUBMIT
    const handleSubmit = async () => {
        if (!user) return alert("User not loaded");
        if (!selectedCourseId) return alert("Please select a module");

        const payload = {
            userid: user.id,
            module_id: selectedCourseId, // STORE COURSE ID
            location_name: searchLocation,
            start_time: convertTo24Hour(startHour, startMinute, startPeriod),
            end_time: convertTo24Hour(endHour, endMinute, endPeriod)
        };

        try {
            const response = await axios.post(`${API_BASE_URL}/create_session`, payload);
            const sessionId = response.data?.sessionid;

            if (!sessionId) {
                alert("❌ Session ID is undefined! Check backend response.");
                return;
            }

            window.location.href = `/session_qr/${sessionId}`;
        } catch (err: any) {
            console.error(err);
            alert(err.response?.data?.detail || "Error creating session");
        }
    };

    if (error) return <div>Error: {error}</div>;

    return (
        <div className="create">
            <div className="form">

                {/* USER ID */}
                <div className="inputcontainer">
                    <div className="label">Index Number</div>
                    <input type="text" className="input" value={user?.username || ""} readOnly />
                </div>

                {/* MODULE SELECT */}
                <div className="inputcontainer">
                    <div className="label">Module Name</div>
                    <div className="select-container" style={{ position: "relative" }}>
                        <input
                            type="text"
                            className="input"
                            placeholder="Type module name"
                            value={searchModule}
                            onChange={(e) => {
                                setSearchModule(e.target.value);
                                setShowModuleDropdown(true);
                            }}
                            onFocus={() => setShowModuleDropdown(true)}
                        />

                        {showModuleDropdown && (
                            <div className="dropdown">
                                {filteredModules.length > 0 ? (
                                    filteredModules.map((course) => (
                                        <div
                                            key={course.id}
                                            className="option"
                                            onClick={() => {
                                                setSearchModule(course.name);
                                                setSelectedCourseId(course.id);
                                                setShowModuleDropdown(false);
                                            }}
                                            style={{
                                                padding: "10px",
                                                cursor: "pointer",
                                                borderBottom: "1px solid #eee"
                                            }}
                                        >
                                            {course.name}
                                        </div>
                                    ))
                                ) : (
                                    <div style={{ padding: "10px" }}>No results</div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* LOCATION SELECT */}
                <div className="inputcontainer">
                    <div className="label">Location Name</div>
                    <div className="select-container" style={{ position: "relative" }}>
                        <input
                            type="text"
                            className="input"
                            placeholder="Lecture hall"
                            value={searchLocation}
                            onChange={(e) => {
                                setSearchLocation(e.target.value);
                                setShowLocationDropdown(true);
                            }}
                            onFocus={() => setShowLocationDropdown(true)}
                        />

                        {showLocationDropdown && (
                            <div className="dropdown">
                                {filteredLocations.length > 0 ? (
                                    filteredLocations.map((loc) => (
                                        <div
                                            key={loc}
                                            className="option"
                                            onClick={() => {
                                                setSearchLocation(loc);
                                                setShowLocationDropdown(false);
                                            }}
                                            style={{
                                                padding: "10px",
                                                cursor: "pointer",
                                                borderBottom: "1px solid #eee"
                                            }}
                                        >
                                            {loc}
                                        </div>
                                    ))
                                ) : (
                                    <div style={{ padding: "10px" }}>No results</div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* TIME */}
                <div className="inputcontainer">
                    <div className="label">Time</div>
                    <div className="time-row">

                        {/* START TIME */}
                        <div className="time-input">
                            <input
                                type="text"
                                placeholder="07"
                                maxLength={2}
                                value={startHour}
                                onChange={(e) => setStartHour(e.target.value)}
                            />
                            <span>:</span>
                            <input
                                type="text"
                                placeholder="00"
                                maxLength={2}
                                value={startMinute}
                                onChange={(e) => setStartMinute(e.target.value)}
                            />
                            <select value={startPeriod} onChange={(e) => setStartPeriod(e.target.value)}>
                                <option value="am">am</option>
                                <option value="pm">pm</option>
                            </select>
                        </div>

                        <span className="to-text">To</span>

                        {/* END TIME */}
                        <div className="time-input">
                            <input
                                type="text"
                                placeholder="07"
                                maxLength={2}
                                value={endHour}
                                onChange={(e) => setEndHour(e.target.value)}
                            />
                            <span>:</span>
                            <input
                                type="text"
                                placeholder="30"
                                maxLength={2}
                                value={endMinute}
                                onChange={(e) => setEndMinute(e.target.value)}
                            />
                            <select value={endPeriod} onChange={(e) => setEndPeriod(e.target.value)}>
                                <option value="am">am</option>
                                <option value="pm">pm</option>
                            </select>
                        </div>
                    </div>
                </div>

                <button className="signin" onClick={handleSubmit}>
                    Next
                </button>

            </div>
        </div>
    );
}

export default Create_Sesstion;
