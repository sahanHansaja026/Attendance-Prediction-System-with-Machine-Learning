import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";
import API_BASE_URL from "../../config/ipconfig";

const API_URL = `${API_BASE_URL}`; // backend root

const register = async (userData: any) => {
  const { data } = await axios.post(`${API_URL}/register/`, userData);
  return data;
};

const login = async (credentials: any) => {
  const { data } = await axios.post(`${API_URL}/login/`, credentials);
  await AsyncStorage.setItem("token", data.token); 
  return data;
};

const getUserData = async () => {
  const token = await AsyncStorage.getItem("token");
  if (!token) throw new Error("No token found");

  try {
    const { data } = await axios.get(`${API_URL}/me/`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return data;

  } catch (error: any) {
    if (error.response?.status === 401) {
      // Token expired, remove it
      await AsyncStorage.removeItem("token");
      throw new Error("Session expired. Please log in again."); // throw custom message
    }
    throw error;
  }
};

export default {
  login,
  register,
  getUserData,
};
