import apiClient from "../api/apiClient";
import { endpoints } from "../api/endpoints";

export const approveAssignment = async (assignmentId) => {
    const response = await apiClient.post(
        endpoints.approveAssignment(assignmentId)
    );

    return response.data;
};

export const rejectAssignment = async (assignmentId) => {
    const response = await apiClient.post(
        endpoints.rejectAssignment(assignmentId)
    );

    return response.data;
};