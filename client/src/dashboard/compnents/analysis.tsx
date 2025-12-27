import React, { useEffect, useState } from "react";
import axios from "axios";
import API_BASE_URL from "../../../config/ipconfig";
import "../../css/AnalysisPage.css";

type TimeRange = "1D" | "7D" | "28D" | "90D" | "6M" | "365D";

const ranges: { label: string; value: TimeRange }[] = [
    { label: "1 Day", value: "1D" },
    { label: "7 Days", value: "7D" },
    { label: "28 Days", value: "28D" },
    { label: "90 Days", value: "90D" },
    { label: "6 Months", value: "6M" },
    { label: "365 Days", value: "365D" },
];

interface AttendanceReport {
    student_id: string;
    student_name: string;
    graduation_year: number;
    course_name: string;
    courseindex: string;
    owner: string;
    location_name: string;
    latitude: string;
    longitude: string;
    mark_at: string;
}

const AnalysisPage: React.FC = () => {
    const [selectedRange, setSelectedRange] = useState<TimeRange>("7D");
    const [selectedYear, setSelectedYear] = useState<number | "All">("All");
    const [searchTerm, setSearchTerm] = useState<string>("");
    const [data, setData] = useState<AttendanceReport[]>([]);
    const [filteredData, setFilteredData] = useState<AttendanceReport[]>([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchAttendance();
    }, []);

    useEffect(() => {
        applyFilters();
    }, [data, selectedRange, selectedYear, searchTerm]);

    const fetchAttendance = async () => {
        try {
            setLoading(true);
            const res = await axios.get(`${API_BASE_URL}/attendance/report`);
            setData(res.data);
        } catch (error) {
            console.error("Failed to load attendance", error);
        } finally {
            setLoading(false);
        }
    };

    const applyFilters = () => {
        const now = new Date();
        let filtered = [...data];

        // Filter by time range
        filtered = filtered.filter((item) => {
            const markDate = new Date(item.mark_at);
            switch (selectedRange) {
                case "1D":
                    return markDate.toDateString() === now.toDateString();
                case "7D":
                    const sevenDaysAgo = new Date();
                    sevenDaysAgo.setDate(now.getDate() - 6);
                    return markDate >= sevenDaysAgo && markDate <= now;
                case "28D":
                    const twentyEightDaysAgo = new Date();
                    twentyEightDaysAgo.setDate(now.getDate() - 27);
                    return markDate >= twentyEightDaysAgo && markDate <= now;
                case "90D":
                    const ninetyDaysAgo = new Date();
                    ninetyDaysAgo.setDate(now.getDate() - 89);
                    return markDate >= ninetyDaysAgo && markDate <= now;
                case "6M":
                    const sixMonthsAgo = new Date();
                    sixMonthsAgo.setMonth(now.getMonth() - 5);
                    return markDate >= sixMonthsAgo && markDate <= now;
                case "365D":
                    const oneYearAgo = new Date();
                    oneYearAgo.setFullYear(now.getFullYear() - 1);
                    return markDate >= oneYearAgo && markDate <= now;
                default:
                    return true;
            }
        });

        // Filter by selected graduation year
        if (selectedYear !== "All") {
            filtered = filtered.filter(
                (item) => item.graduation_year === selectedYear
            );
        }

        // Filter by search term (all columns)
        if (searchTerm.trim() !== "") {
            const term = searchTerm.toLowerCase();
            filtered = filtered.filter((item) =>
                Object.values(item).some((val) =>
                    val
                        .toString()
                        .toLowerCase()
                        .includes(term)
                )
            );
        }

        setFilteredData(filtered);
    };

    // Get unique graduation years for dropdown
    const getGraduationYears = () => {
        const years = Array.from(
            new Set(data.map((item) => item.graduation_year))
        );
        return years.sort((a, b) => b - a);
    };

    return (
        <div className="analysis-page">
            {/* Time range buttons */}
            <div className="time-range-container">
                {ranges.map((range) => (
                    <button
                        key={range.value}
                        className={`time-range-btn ${selectedRange === range.value ? "active" : ""}`}
                        onClick={() => {
                            setSelectedRange(range.value);
                            setSelectedYear("All");
                        }}
                    >
                        {range.label}
                    </button>
                ))}
            </div>

            {/* Graduation Year Dropdown */}
            <div className="year-select-container">
                <label htmlFor="year-select">Select Graduation Year: </label>
                <select
                    id="year-select"
                    value={selectedYear}
                    onChange={(e) =>
                        setSelectedYear(
                            e.target.value === "All" ? "All" : parseInt(e.target.value)
                        )
                    }
                >
                    <option value="All">All</option>
                    {getGraduationYears().map((year) => (
                        <option key={year} value={year}>
                            {year}
                        </option>
                    ))}
                </select>
            </div>

            {/* Search Input */}
            <div className="search-container">
                <input
                    type="text"
                    placeholder="Search..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </div>

            {/* Table */}
            {loading ? (
                <p className="loading">Loading...</p>
            ) : (
                <div className="table-wrapper">
                    <table className="analysis-table">
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Year</th>
                                <th>Course</th>
                                <th>Course Index</th>
                                <th>Owner</th>
                                <th>Location</th>
                                <th>Date</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredData.length === 0 ? (
                                <tr>
                                    <td colSpan={9} className="no-data">
                                        No attendance records found
                                    </td>
                                </tr>
                            ) : (
                                filteredData.map((item, index) => {
                                    const date = new Date(item.mark_at);
                                    return (
                                        <tr key={index}>
                                            <td>{item.student_id}</td>
                                            <td>{item.student_name}</td>
                                            <td>{item.graduation_year}</td>
                                            <td>{item.course_name}</td>
                                            <td>{item.courseindex}</td>
                                            <td>{item.owner}</td>
                                            <td>{item.location_name}</td>
                                            <td>{date.toLocaleDateString()}</td>
                                            <td>{date.toLocaleTimeString()}</td>
                                        </tr>
                                    );
                                })
                            )}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
};

export default AnalysisPage;
