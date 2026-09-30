import apiClient from "../api/apiClient";
import { endpoints } from "../api/endpoints";

export const login = async (email, password) => {
    const response = await apiClient.post(endpoints.login, {
        email,
        password,
    });

    return response.data;
};

export const logout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
};

export const saveAuth = (token, user) => {
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(user));
};

export const getCurrentUser = () => {
    const user = localStorage.getItem("user");

    if (!user) {
        return null;
    }

    try {
        return JSON.parse(user);
    } catch {
        return null;
    }
};