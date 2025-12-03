import React, { useState, useEffect } from "react";
import authService from "../services/authService";
import "../css/dashboards.css";
import HomeIcon from "../assets/images/icon1.svg";
import AnalaysisIcon from "../assets/images/analy.svg";
import HistoryIcon from "../assets/images/icon3.svg";
import LOgoutIcon from "../assets/images/icon2.svg";
import { useNavigate } from "react-router-dom";

// components
import HomePage from "./compnents/create";

type User = {
    username: string;
    email: string;
    id: number;
};

export default function Dashboard() {
    const [user, setUser] = useState<User | null>(null);
    const [error, setError] = useState<string>("");
    const [activePage, setActivePage] = useState("home");
    const pageTitles: Record<string, string> = {
        home: "Create Session",
        analysis: "Analytics",
        history: "History"
    };
    const navigate = useNavigate();



    useEffect(() => {
        const fetchUserData = async () => {
            try {
                const userData = await authService.getUserData();
                setUser(userData);
            } catch (error: any) {
                // If token expired, alert user then navigate to login
                if (error.message === "Session expired. Please log in again.") {
                    alert(error.message); // show alert
                    navigate("/");    
                } else {
                    console.error("Unknown error fetching user data:", error);
                }
            }
        };

        fetchUserData();
    }, [navigate]);

    if (error) return <div>Error: {error}</div>;

    const handleLogout = () => {
        // remove token and any stored user data
        localStorage.removeItem("token");
        localStorage.removeItem("username");

        // optionally, show alert before logout
        if (window.confirm("Are you sure you want to logout?")) {
            navigate("/");
        }
    };

    return (
        <div className="dashboard">
            <div className="container">
                <div className="topbar">
                    <div className="topcontainer1">
                        <div className="title">{pageTitles[activePage]}</div>
                    </div>

                    <div className="userprofile">
                        {user ? (
                            <div>
                                <p>{user.username}</p>
                            </div>
                        ) : (
                            <p>Loading user data...</p>
                        )}
                    </div>
                </div>
            </div>
            <div className="maincontainer">
                <div className="sidebar">
                    <div
                        className={`sidebar-item ${activePage === "home" ? "active" : ""}`}
                        onClick={() => setActivePage("home")}
                    >
                        <img src={HomeIcon} alt="Home" className="icon" />
                    </div>

                    <div
                        className={`sidebar-item ${activePage === "analysis" ? "active" : ""}`}
                        onClick={() => setActivePage("analysis")}
                    >
                        <img src={AnalaysisIcon} alt="analysis" className="icon" />
                    </div>

                    <div
                        className={`sidebar-item ${activePage === "history" ? "active" : ""}`}
                        onClick={() => setActivePage("history")}
                    >
                        <img src={HistoryIcon} alt="history" className="icon" />
                    </div>

                    <div
                        className={`sidebar-item ${activePage === "history" ? "active" : ""}`}
                        onClick={handleLogout}
                    >
                        <img src={LOgoutIcon} alt="Logout" className="icon" />
                    </div>
                </div>

                <div className="pagecontainer">
                    {activePage === "home" && <HomePage />}
                    {activePage === "analysis" && <div>Analysis Page Content</div>}
                    {activePage === "history" && <div>History Page Content</div>}
                </div>

            </div>
            
        </div>
    );
}
