import React, { useState } from "react";
import "../css/login.css";
import LoginImage from "../assets/images/login.svg";
import axios from "axios";
import API_BASE_URL from "../../config/ipconfig"

export default function SignUp() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [username, setUsername] = useState("");
    const [message, setMessage] = useState("");

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const response = await axios.post(`${API_BASE_URL}/register/`, {
                email,
                username,
                password,
            });
            setMessage(response.data.message);
        } catch (err) {
            const error = err as any; // <-- Type assertion
            if (error.response) {
                setMessage(error.response.data.detail);
            } else {
                setMessage("Something went wrong!");
            }
        }
    };

    return (
        <div className="container">
            <div className="subcontainer">
                <p>
                    Sign In To <br />
                    SLTC Attendance <br />
                    Management System
                </p>
                <img src={LoginImage} alt="Logo" className="imageclass" />
            </div>

            <div className="formcontainer">
                <div className="inputcontainer">
                    <label className="label">Index Number:</label>

                    <input
                        type="text"
                        className="input"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        placeholder="CAT2 XXXX"
                    />
                </div>

                <div className="inputcontainer">
                    <label className="label">Email:</label>

                    <input
                        type="email"
                        className="input"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="example@sltc.ac.lk"
                    />
                </div>

                <div className="inputcontainer">
                    <label className="label">Password:</label>

                    <input
                        type="password"
                        className="input"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="***************"
                    />
                </div>

                <button className="google-btn">
                    <img
                        src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxBdeC5Y3EFki1imz0xNWdvrP8W3fixFY0fqWzmmJDVHrkvK2_sphGxlRcIJi1D3x6MHg&usqp=CAU"
                        alt="Google Logo"
                        className="google-logo"
                    />
                    Sign in with Google
                </button>

                <button className="signin" onClick={handleSubmit}>
                    Sign in
                </button>
                <div className="navigate">
                    <a href="/" className="navigate-link">
                        login Your Account
                        <span className="underline"></span>
                    </a>
                </div>

            </div>
        </div>
    );
}
