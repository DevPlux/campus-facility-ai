import apiClient from "../api/apiClient";
import { endpoints } from "../api/endpoints";

export const getTechnicians = async () => {
    const response = await apiClient.get(
        endpoints.technicians
    );

    return response.data;
};