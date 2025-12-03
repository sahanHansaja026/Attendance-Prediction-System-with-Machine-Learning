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

function Create_Sesstion() {
    const [user, setUser] = useState<User | null>(null);
    const [error, setError] = useState<string>("");

    // TIME
    const [startHour, setStartHour] = useState("");
    const [startMinute, setStartMinute] = useState("");
    const [startPeriod, setStartPeriod] = useState("am");

    const [endHour, setEndHour] = useState("");
    const [endMinute, setEndMinute] = useState("");
    const [endPeriod, setEndPeriod] = useState("am");

    // MODULE SEARCH
    const [searchModule, setSearchModule] = useState("");
    const [showModuleDropdown, setShowModuleDropdown] = useState(false);

    // LOCATION SEARCH
    const [searchLocation, setSearchLocation] = useState("");
    const [showLocationDropdown, setShowLocationDropdown] = useState(false);

    // COURSES FROM BACKEND
    const [courses, setCourses] = useState<string[]>([]);

    // LOCATION OPTIONS
    const locationList = ["Hall A", "Hall B", "Hall C", "Lab 1", "Lab 2", "Lab 3"];
    const filteredLocations = locationList.filter((item) =>
        item.toLowerCase().includes(searchLocation.toLowerCase())
    );

    // FILTER MODULES
    const filteredModules = courses.filter((item) =>
        item.toLowerCase().includes(searchModule.toLowerCase())
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
                const courseNames = res.data.map((course: any) => course.course_name);
                setCourses(courseNames);
            } catch (err) {
                console.error("Error fetching courses:", err);
            }
        };

        fetchUserData();
        fetchCourses();
    }, []);

    // HELPER: Convert time to 24h format
    const convertTo24Hour = (hour: string, minute: string, period: string) => {
        let h = parseInt(hour);
        if (period === "pm" && h !== 12) h += 12;
        if (period === "am" && h === 12) h = 0;
        const mm = minute.padStart(2, "0");
        return `${h.toString().padStart(2, "0")}:${mm}:00`;
    };

    const handleSubmit = async () => {
        if (!user) return alert("User not loaded");

        const start_time = convertTo24Hour(startHour, startMinute, startPeriod);
        const end_time = convertTo24Hour(endHour, endMinute, endPeriod);

        const payload = {
            userid: user.id,
            module_name: searchModule,
            location_name: searchLocation,
            start_time,
            end_time,
        };

        try {
            const response = await axios.post(`${API_BASE_URL}/create_session`, payload);
            const sessionId = response.data?.sessionid;
            if (!sessionId) {
                alert("❌ Session ID is undefined! Check backend response and API_BASE_URL");
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
                    <input
                        type="text"
                        className="input"
                        value={user ? user.username : ""}
                        readOnly
                    />
                </div>

                {/* MODULE SEARCH */}
                <div className="inputcontainer">
                    <div className="label">Module Name</div>
                    <div className="select-container" style={{ position: "relative" }}>
                        <input
                            type="text"
                            className="input"
                            placeholder="Type your module code or name"
                            value={searchModule}
                            onChange={(e) => {
                                setSearchModule(e.target.value);
                                setShowModuleDropdown(true);
                                setShowLocationDropdown(false);
                            }}
                            onFocus={() => {
                                setShowModuleDropdown(true);
                                setShowLocationDropdown(false);
                            }}
                        />
                        {showModuleDropdown && (
                            <div
                                className="dropdown">
                                {filteredModules.length > 0 ? (
                                    filteredModules.map((option) => (
                                        <div
                                            key={option}
                                            className="option"
                                            style={{
                                                padding: "10px",
                                                cursor: "pointer",
                                                borderBottom: "1px solid #eee",
                                            }}
                                            onClick={() => {
                                                setSearchModule(option);
                                                setShowModuleDropdown(false);
                                            }}
                                        >
                                            {option}
                                        </div>
                                    ))
                                ) : (
                                    <div style={{ padding: "10px" }}>No results</div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* LOCATION SEARCH */}
                <div className="inputcontainer">
                    <div className="label">Location Name</div>
                    <div className="select-container" style={{ position: "relative" }}>
                        <input
                            type="text"
                            className="input"
                            placeholder="In your lecture hall or virtual room"
                            value={searchLocation}
                            onChange={(e) => {
                                setSearchLocation(e.target.value);
                                setShowLocationDropdown(true);
                                setShowModuleDropdown(false);
                            }}
                            onFocus={() => {
                                setShowLocationDropdown(true);
                                setShowModuleDropdown(false);
                            }}
                        />
                        {showLocationDropdown && (
                            <div
                                className="dropdown">
                                {filteredLocations.length > 0 ? (
                                    filteredLocations.map((option) => (
                                        <div
                                            key={option}
                                            className="option"
                                            style={{
                                                padding: "10px",
                                                cursor: "pointer",
                                                borderBottom: "1px solid #eee",
                                            }}
                                            onClick={() => {
                                                setSearchLocation(option);
                                                setShowLocationDropdown(false);
                                            }}
                                        >
                                            {option}
                                        </div>
                                    ))
                                ) : (
                                    <div style={{ padding: "10px" }}>No results</div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* TIME SELECTION */}
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
                            <select
                                value={startPeriod}
                                onChange={(e) => setStartPeriod(e.target.value)}
                            >
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
                            <select
                                value={endPeriod}
                                onChange={(e) => setEndPeriod(e.target.value)}
                            >
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
