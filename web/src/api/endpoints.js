export const API_BASE_URL =
    "http://YOUR_BACKEND_IP:PORT/api";

export const endpoints = {
    login: "/auth/login",

    issues: "/issues",

    issueById: (id) => `/issues/${id}`,

    analyzeIssue: (id) =>
        `/issues/${id}/analyze`,

    recommendTechnician: (id) =>
        `/issues/${id}/recommend-technician`,

    technicians: "/technicians",

    approveAssignment: (id) =>
        `/assignments/${id}/approve`,

    rejectAssignment: (id) =>
        `/assignments/${id}/reject`,
};