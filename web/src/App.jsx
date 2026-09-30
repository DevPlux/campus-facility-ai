import { Navigate, Route, Routes } from "react-router-dom";

import LoginPage from "./pages/LoginPage";
import DashboardPage from "./pages/DashboardPage";
import IssuesPage from "./pages/IssuesPage";
import IssueDetailsPage from "./pages/IssueDetailsPage";
import TechniciansPage from "./pages/TechniciansPage";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/login" />} />

      <Route path="/login" element={<LoginPage />} />

      <Route path="/dashboard" element={<DashboardPage />} />

      <Route path="/issues" element={<IssuesPage />} />

      <Route path="/issues/:id" element={<IssueDetailsPage />} />

      <Route path="/technicians" element={<TechniciansPage />} />

      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  );
}

export default App;
