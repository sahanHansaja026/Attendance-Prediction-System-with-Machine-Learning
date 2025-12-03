import React, { Component } from 'react';
import { BrowserRouter, Routes, Route } from "react-router-dom";

import LoginPage from "./auth/login";
import SignUpPage from './auth/signup';
import DashboardPage from './dashboard/dashboard';
import SessionQR from './dashboard/compnents/qrcode';

export default class App extends Component {
  render() {
    return (
      <BrowserRouter>
        <Routes>
          <Route path='/' element={<LoginPage />} />
          <Route path='/signin' element={<SignUpPage />} />
          <Route path='/dashboard' element={<DashboardPage />} />
          <Route path="/session_qr/:sessionId" element={<SessionQR />} />

        </Routes>
      </BrowserRouter>
    )
  }
}
