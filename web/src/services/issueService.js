import apiClient from "../api/apiClient";
import { endpoints } from "../api/endpoints";

export const getIssues = async () => {
    const response = await apiClient.get(
        endpoints.issues
    );

    return response.data;
};

export const getIssueById = async (id) => {
    const response = await apiClient.get(
        endpoints.issueById(id)
    );

    return response.data;
};