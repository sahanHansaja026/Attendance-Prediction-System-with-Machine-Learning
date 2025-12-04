import React, { useState } from "react";
import "../../css/adduser.css";
import axios from "axios";
import API_BASE_URL from "../../../config/ipconfig"; // your backend base URL

function AddGust() {
    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [index, setIndex] = useState("");
    const [graduationYear, setGraduationYear] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");

    const [passwordError, setPasswordError] = useState("");
    const [confirmError, setConfirmError] = useState("");

    const [loading, setLoading] = useState(false);


    const checkPasswordStrength = (value: string) => {
        setPassword(value);
        if (value.length < 8) {
            setPasswordError("Password must be at least 8 characters long");
        } else if (!/[A-Z]/.test(value)) {
            setPasswordError("Password must contain at least one uppercase letter");
        } else if (!/[a-z]/.test(value)) {
            setPasswordError("Password must contain at least one lowercase letter");
        } else if (!/[0-9]/.test(value)) {
            setPasswordError("Password must contain at least one number");
        } else if (!/[@$!%*?&#]/.test(value)) {
            setPasswordError("Password must contain at least one special character");
        } else {
            setPasswordError("");
        }
    };

    const checkConfirmPassword = (value: string) => {
        setConfirmPassword(value);
        if (value !== password) {
            setConfirmError("Passwords do not match");
        } else {
            setConfirmError("");
        }
    };

    const handleSubmit = async () => {
        if (!name || !email || !index || !graduationYear || !password) {
            alert("All fields are required!");
            return;
        }
        if (passwordError || confirmError) {
            alert("Fix validation errors before submitting!");
            return;
        }

        const gustData = {
            name,
            email,
            index,
            graduation_year: Number(graduationYear),
            password
        };

        setLoading(true); // 🔥 start loading
        try {
            const res = await axios.post(`${API_BASE_URL}/add_gust`, gustData);

            if (res.status === 200) {
                alert("Gust added successfully!");
                setName("");
                setEmail("");
                setIndex("");
                setGraduationYear("");
                setPassword("");
                setConfirmPassword("");
            }

        } catch (error: any) {
            if (error.response && error.response.data) {
                alert(error.response.data.detail || "Error adding gust");
            } else {
                console.error(error);
                alert("Server error");
            }
        } finally {
            setLoading(false); // 🔥 stop loading
        }
    };


    return (
        <div className="adduser">
            <div className="form">
                {/* Full Name */}
                <div className="inputcontainer">
                    <label className="label">Full Name:</label>
                    <input
                        type="text"
                        className="input"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        placeholder="Type Full Name"
                    />
                </div>

                <div className="batchcontainer">
                    {/* Index */}
                    <div className="bagap">
                        <div className="inputcontainer">
                            <label className="label">Index Number:</label>
                            <input
                                type="text"
                                className="input"
                                value={index}
                                onChange={(e) => setIndex(e.target.value)}
                                placeholder="CAT 0265"
                            />
                        </div>
                    </div>

                    {/* Graduation Year */}
                    <div className="bagap">
                        <div className="inputcontainer">
                            <label className="label">Graduation Year:</label>
                            <select
                                className="select"
                                value={graduationYear}
                                onChange={(e) => setGraduationYear(e.target.value)}
                            >
                                <option value="">Select Year</option>
                                {Array.from({ length: 7 }, (_, i) => {
                                    const year = new Date().getFullYear() + i;
                                    return (
                                        <option key={year} value={year}>
                                            {year}
                                        </option>
                                    );
                                })}
                            </select>
                        </div>
                    </div>
                </div>

                {/* Email */}
                <div className="inputcontainer">
                    <label className="label">Email:</label>
                    <input
                        type="text"
                        className="input"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="example@sltc.ac.lk"
                    />
                </div>

                {/* Password */}
                <div className="inputcontainer">
                    <label className="label">Password:</label>
                    <input
                        type="password"
                        className={`input ${passwordError ? "input-error" : ""}`}
                        value={password}
                        onChange={(e) => checkPasswordStrength(e.target.value)}
                        placeholder="**************"
                    />
                    {passwordError && <p className="error-text">{passwordError}</p>}
                </div>

                {/* Confirm Password */}
                <div className="inputcontainer">
                    <label className="label">Confirm Password:</label>
                    <input
                        type="password"
                        className={`input ${confirmError ? "input-error" : ""}`}
                        value={confirmPassword}
                        onChange={(e) => checkConfirmPassword(e.target.value)}
                        placeholder="Confirm Password"
                    />
                    {confirmError && <p className="error-text">{confirmError}</p>}
                </div>

                <button className="adduserbtn" onClick={handleSubmit} disabled={loading}>
                    {loading ? (
                        <span className="spinner"></span> // spinner
                    ) : (
                        "Add Gust"
                    )}
                </button>

            </div>
        </div>
    );
}

export default AddGust;
