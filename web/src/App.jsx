import { Navigate, Route, Routes } from "react-router-dom";

import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";

import DashboardPage from "./pages/DashboardPage";
import IssueDetailsPage from "./pages/IssueDetailsPage";
import IssuesPage from "./pages/IssuesPage";
import LoginPage from "./pages/LoginPage";
import TechniciansPage from "./pages/TechniciansPage";

function App() {
  return (
    <Routes>
      {/* Default */}

      <Route path="/" element={<Navigate to="/dashboard" replace />} />

      {/* Public */}

      <Route path="/login" element={<LoginPage />} />

      {/* Manager Protected Routes */}

      <Route element={<ProtectedRoute />}>
        <Route element={<Layout />}>
          <Route path="/dashboard" element={<DashboardPage />} />

          <Route path="/issues" element={<IssuesPage />} />

          <Route path="/issues/:id" element={<IssueDetailsPage />} />

          <Route path="/technicians" element={<TechniciansPage />} />
        </Route>
      </Route>

      {/* Unknown Route */}

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}

export default App;
