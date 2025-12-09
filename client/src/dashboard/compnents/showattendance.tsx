import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import "../../css/showattendance.css";
import API_BASE_URL from '../../../config/ipconfig';
import { GoogleMap, LoadScript, Marker } from "@react-google-maps/api";

interface AttendanceRecord {
    index: string;
    time: string;
    date: string;
    latitude: string;
    longitude: string;
}

function ShowAttendancePage() {
    const { sessionId } = useParams<{ sessionId: string }>();
    const [attendanceData, setAttendanceData] = useState<AttendanceRecord[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        fetchAttendance();
    }, [sessionId]);

    const fetchAttendance = async () => {
        try {
            const res = await axios.get(`${API_BASE_URL}/attendances/${sessionId}`);
            const formattedData: AttendanceRecord[] = res.data.map((att: any) => {
                const dateObj = new Date(att.mark_at);
                return {
                    index: att.student_id,
                    time: dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                    date: dateObj.toLocaleDateString(),
                    latitude: att.latitude,
                    longitude: att.longitude
                };
            });
            setAttendanceData(formattedData);
            setLoading(false);
        } catch (err) {
            console.error(err);
            setError("Failed to fetch attendance data.");
            setLoading(false);
        }
    };

    const containerStyle = {
        width: "100%",
        height: "400px"
    };

    const center = attendanceData.length > 0
        ? { lat: parseFloat(attendanceData[0].latitude), lng: parseFloat(attendanceData[0].longitude) }
        : { lat: 6.9271, lng: 79.8612 }; // Default to Colombo

    if (loading) return <p>Loading attendance...</p>;
    if (error) return <p>{error}</p>;

    return (
        <div className='attendacepage'>
            <h2>Attendance Records</h2>
        <div className="attendance-container">

            <table className="attendance-table">
                <thead>
                    <tr>
                        <th>Student Index</th>
                        <th>Time</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    {attendanceData.map((record, index) => (
                        <tr key={index}>
                            <td>{record.index}</td>
                            <td>{record.time}</td>
                            <td>{record.date}</td>
                        </tr>
                    ))}
                </tbody>
            </table>

                <LoadScript googleMapsApiKey={import.meta.env.VITE_GOOGLE_MAPS_API_KEY}>
                    <div className="google-map-container">
                        <GoogleMap
                            mapContainerStyle={{ width: '100%', height: '100%' }}
                            center={center}
                            zoom={12}
                        >
                            {attendanceData.map((record, index) => (
                                <Marker
                                    key={index}
                                    position={{
                                        lat: parseFloat(record.latitude),
                                        lng: parseFloat(record.longitude)
                                    }}
                                    title={record.index}
                                />
                            ))}
                        </GoogleMap>
                    </div>
                </LoadScript>
            </div>
        </div>
    );
}

export default ShowAttendancePage;
