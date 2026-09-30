import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";

function Layout() {
  return (
    <div className="min-h-screen bg-[#F7F8FA]">
      <Sidebar />

      <main className="min-h-screen lg:ml-[248px]">
        <div className="mx-auto max-w-[1500px] px-5 py-7 sm:px-7 lg:px-9">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

export default Layout;
