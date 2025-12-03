import React, { useState } from "react";
import "../css/login.css";
import LoginImage from "../assets/images/login.svg";
import axios from "axios";
import API_BASE_URL from "../../config/ipconfig";
import { useNavigate } from "react-router-dom";


export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const navigate = useNavigate();


  const handleLogin = async (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();

    try {
      const response = await axios.post(`${API_BASE_URL}/login/`, {
        email,
        password,
      });

      const { token, username } = response.data;

      localStorage.setItem("token", token);
      localStorage.setItem("username", username);

      setMessage("Login successful!");

      navigate("/dashboard");
      
    } catch (err: unknown) {
      if (axios.isAxiosError(err)) {
        setMessage(err.response?.data?.detail || "Login failed!");
      } else {
        setMessage("An unexpected error occurred!");
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

        <button className="signin" onClick={handleLogin}>
          Sign in
        </button>
        <div className="navigate">
          <a href="/signin" className="navigate-link">
            Create Your Account
            <span className="underline"></span>
          </a>
        </div>

      </div>
    </div>
  );
}
