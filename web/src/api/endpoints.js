
export const API_BASE_URL =
    import.meta.env.VITE_API_BASE_URL ||
    "https://campus-facility-ai.onrender.com/api";

export const endpoints = {
    // Authentication
    login: "/auth/login",

    // Issues
    issues: "/issues",
    issueById: (id) => `/issues/${id}`,

    // Technicians
    technicians: "/technicians",

    // Assignments
    approveAssignment: (id) =>
        `/assignments/${id}/approve`,

    rejectAssignment: (id) =>
        `/assignments/${id}/reject`,
};
