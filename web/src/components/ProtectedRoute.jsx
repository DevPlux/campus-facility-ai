import { Navigate, Outlet } from "react-router-dom";
import { getCurrentUser } from "../services/authService";

function ProtectedRoute() {
  const token = localStorage.getItem("token");
  const user = getCurrentUser();

  if (!token || !user) {
    return <Navigate to="/login" replace />;
  }

  if (user.role !== "MANAGER") {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}

export default ProtectedRoute;
