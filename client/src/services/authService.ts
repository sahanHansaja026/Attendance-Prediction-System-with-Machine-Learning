import axios from "axios";
import API_BASE_URL from "../../config/ipconfig";

const API_URL = `${API_BASE_URL}`;

const register = async (userData: any) => {
  const { data } = await axios.post(`${API_URL}/register/`, userData);
  return data;
};

const login = async (credentials: any) => {
  const { data } = await axios.post(`${API_URL}/login/`, credentials);
  localStorage.setItem("token", data.token);
  return data;
};

const getUserData = async () => {
  const token = localStorage.getItem("token");
  if (!token) throw new Error("No token found");

  try {
    const { data } = await axios.get(`${API_URL}/me/`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return data;
  } catch (error: any) {
    if (error.response?.status === 401) {
      localStorage.removeItem("token");
      throw new Error("Session expired. Please log in again.");
    }
    throw error;
  }
};

export default {
  login,
  register,
  getUserData,
};
