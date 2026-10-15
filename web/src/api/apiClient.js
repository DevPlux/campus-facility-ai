
import axios from "axios";
import { API_BASE_URL } from "./endpoints";

const apiClient = axios.create({
    baseURL: API_BASE_URL,
    timeout: 60000,
    headers: {
        Accept: "application/json",
    },
});

// Attach JWT token to API requests
apiClient.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("token");

        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }

        return config;
    },
    (error) => Promise.reject(error)
);

// Handle unauthorized responses
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            const isLoginRequest =
                error.config?.url?.includes("/auth/login");

            if (!isLoginRequest) {
                localStorage.removeItem("token");
                localStorage.removeItem("user");

                if (window.location.pathname !== "/login") {
                    window.location.href = "/login";
                }
            }
        }

        return Promise.reject(error);
    }
);

export default apiClient;
