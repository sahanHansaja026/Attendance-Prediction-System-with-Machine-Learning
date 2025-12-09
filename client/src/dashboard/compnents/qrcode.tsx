import React, { useEffect, useState } from "react";
import QRCode from "react-qr-code";
import axios from "axios";
import API_BASE_URL from "../../../config/ipconfig";
import "../../css/token.css";
import { useParams, useNavigate } from "react-router-dom";

interface ShowUsersProps {
    setActivePage: (page: string) => void;
}

function SessionQR({ setActivePage }: ShowUsersProps) {
    const { sessionId } = useParams();
    const [pin, setPin] = useState("");
    const [token, setToken] = useState("");
    const navigate = useNavigate();

    useEffect(() => {
        fetchPin();
        const interval = setInterval(fetchPin, 60000);
        return () => clearInterval(interval);
    }, [sessionId]);

    const fetchPin = async () => {
        try {
            const res = await axios.get(`${API_BASE_URL}/session/${sessionId}/get_pin`);
            setPin(res.data.pin);
            setToken(res.data.token);
        } catch (error) {
            console.log("Error fetching PIN", error);
        }
    };

    const cancelSession = async (sessionId: number) => {
        try {
            const res = await axios.delete(`${API_BASE_URL}/delete_session/${sessionId}`);
            console.log(res.data);
            alert("Session cancelled successfully!");
            navigate("/dashboard");
        } catch (err) {
            console.error(err);
            alert("Failed to cancel session.");
        }
    };

    const handleNext = () => {
        // Navigate to showattendance with sessionId as query or param
        navigate(`/showattendance/${sessionId}`);
    };

    // ⭐ Dynamic QR Code URL
    const qrValue =
        pin && token
            ? `${API_BASE_URL}/attendance/session/${sessionId}?otp=${pin}&token=${token}`
            : "Loading...";

    return (
        <div className="token">
            <p className="titleofqr">Mark Your Attendance</p>
            <QRCode value={qrValue} size={250} />

            <p className="pin">{pin}</p>

            <div className="btnsepcontainer">
                <div className="cancelbtn">
                    <button
                        className="cancel"
                        onClick={() => {
                            if (sessionId) cancelSession(Number(sessionId));
                        }}
                    >
                        Cancel
                    </button>
                </div>

                <div className="nextbtn">
                    <button
                        className="next"
                        onClick={() => {
                            handleNext();
                            setActivePage("attendaceshow");
                        }}
                    >
                        Next
                    </button>

                </div>
            </div>
        </div>
    );
}

export default SessionQR;