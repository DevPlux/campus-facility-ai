import { NavLink, useNavigate } from "react-router-dom";
import {
  LayoutDashboard,
  ClipboardList,
  UsersRound,
  LogOut,
  Building2,
  ChevronRight,
} from "lucide-react";

import { getCurrentUser, logout } from "../services/authService";

function Sidebar() {
  const navigate = useNavigate();
  const user = getCurrentUser();

  const navItems = [
    {
      to: "/dashboard",
      label: "Dashboard",
      icon: LayoutDashboard,
    },
    {
      to: "/issues",
      label: "Issues",
      icon: ClipboardList,
    },
    {
      to: "/technicians",
      label: "Technicians",
      icon: UsersRound,
    },
  ];

  const initials = user?.name
    ? user.name
        .split(" ")
        .filter(Boolean)
        .slice(0, 2)
        .map((word) => word[0])
        .join("")
        .toUpperCase()
    : "M";

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <aside className="fixed inset-y-0 left-0 z-40 hidden w-[248px] border-r border-slate-200 bg-white lg:flex lg:flex-col">
      {/* Brand */}
      <div className="flex h-[72px] items-center border-b border-slate-100 px-6">
        <div className="flex items-center gap-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
            <Building2
              className="h-[18px] w-[18px] text-white"
              strokeWidth={2.2}
            />
          </div>

          <div>
            <p className="text-[14px] font-bold tracking-tight text-slate-900">
              Campus Facility
            </p>
            <p className="text-[10px] font-semibold uppercase tracking-[0.12em] text-slate-400">
              AI Management
            </p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 px-4 py-6">
        <p className="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-400">
          Workspace
        </p>

        <nav className="space-y-1">
          {navItems.map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              className={({ isActive }) =>
                `group flex h-11 items-center gap-3 rounded-lg px-3 text-[13px] font-semibold transition ${
                  isActive
                    ? "bg-blue-50 text-blue-700"
                    : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
                }`
              }
            >
              {({ isActive }) => (
                <>
                  <Icon
                    className={`h-[18px] w-[18px] ${
                      isActive
                        ? "text-blue-600"
                        : "text-slate-400 group-hover:text-slate-600"
                    }`}
                    strokeWidth={2}
                  />

                  <span className="flex-1">{label}</span>

                  {isActive && (
                    <ChevronRight className="h-4 w-4 text-blue-500" />
                  )}
                </>
              )}
            </NavLink>
          ))}
        </nav>
      </div>

      {/* User */}
      <div className="border-t border-slate-100 p-4">
        {user && (
          <div className="mb-3 flex items-center gap-3 px-2">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-slate-900 text-[11px] font-bold text-white">
              {initials}
            </div>

            <div className="min-w-0 flex-1">
              <p className="truncate text-[12px] font-semibold text-slate-900">
                {user.name}
              </p>

              <p className="truncate text-[10.5px] text-slate-400">
                {user.email}
              </p>
            </div>
          </div>
        )}

        <button
          onClick={handleLogout}
          className="flex h-10 w-full items-center justify-center gap-2 rounded-lg border border-slate-200 bg-white text-[12px] font-semibold text-slate-600 transition hover:bg-slate-50 hover:text-red-600"
        >
          <LogOut className="h-4 w-4" />
          Sign out
        </button>
      </div>
    </aside>
  );
}

export default Sidebar;
