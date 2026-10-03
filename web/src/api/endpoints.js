export const API_BASE_URL =
    "http://localhost:5066/api";

export const endpoints = {
    // Authentication
    login: "/auth/login",

    // Issues
    issues: "/issues",

    issueById: (id) =>
        `/issues/${id}`,

    // Technicians
    technicians: "/technicians",

    // Assignments
    approveAssignment: (id) =>
        `/assignments/${id}/approve`,

    rejectAssignment: (id) =>
        `/assignments/${id}/reject`,
};