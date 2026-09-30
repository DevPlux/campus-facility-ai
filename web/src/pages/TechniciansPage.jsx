import { useEffect, useMemo, useState } from "react";

import {
  AlertCircle,
  RefreshCw,
  Search,
  UsersRound,
  Wrench,
} from "lucide-react";

import { getTechnicians } from "../services/technicianService";

function TechniciansPage() {
  const [technicians, setTechnicians] = useState([]);

  const [search, setSearch] = useState("");

  const [loading, setLoading] = useState(true);

  const [error, setError] = useState("");

  const loadTechnicians = async () => {
    try {
      setLoading(true);
      setError("");

      const data = await getTechnicians();

      setTechnicians(Array.isArray(data) ? data : []);
    } catch {
      setError("Unable to retrieve technician data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const initialLoad = async () => {
      try {
        const data = await getTechnicians();

        if (!cancelled) {
          setTechnicians(Array.isArray(data) ? data : []);
        }
      } catch {
        if (!cancelled) {
          setError("Unable to retrieve technician data.");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    initialLoad();

    return () => {
      cancelled = true;
    };
  }, []);

  const filtered = useMemo(() => {
    const value = search.trim().toLowerCase();

    if (!value) return technicians;

    return technicians.filter(
      (technician) =>
        technician.name?.toLowerCase().includes(value) ||
        technician.email?.toLowerCase().includes(value) ||
        technician.skill?.toLowerCase().includes(value),
    );
  }, [technicians, search]);

  const availableCount = technicians.filter(
    (technician) => technician.isAvailable,
  ).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-blue-600">
            Workforce
          </p>

          <h1 className="mt-1 text-[26px] font-bold tracking-tight text-slate-900">
            Technicians
          </h1>

          <p className="mt-1 text-[13px] text-slate-500">
            Monitor technician skills and current availability.
          </p>
        </div>

        <button
          onClick={loadTechnicians}
          disabled={loading}
          className="flex h-10 items-center gap-2 self-start rounded-lg border border-slate-200 bg-white px-4 text-[12px] font-semibold text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:opacity-50"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </button>
      </header>

      {/* Summary */}
      <section className="grid gap-4 sm:grid-cols-3">
        <SummaryCard
          label="Total Technicians"
          value={technicians.length}
          icon={UsersRound}
        />

        <SummaryCard
          label="Available"
          value={availableCount}
          icon={Wrench}
          green
        />

        <SummaryCard
          label="Currently Busy"
          value={technicians.length - availableCount}
          icon={UsersRound}
          amber
        />
      </section>

      {/* Directory */}
      <section className="overflow-hidden rounded-xl border border-slate-200 bg-white">
        <div className="flex flex-col gap-3 border-b border-slate-100 p-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-[13px] font-bold text-slate-800">
              Technician Directory
            </h2>

            <p className="mt-0.5 text-[10px] text-slate-400">
              {filtered.length} technicians
            </p>
          </div>

          <div className="relative w-full sm:w-[310px]">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />

            <input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search name, email or skill..."
              className="h-9 w-full rounded-lg border border-slate-200 pl-9 pr-3 text-[11.5px] outline-none placeholder:text-slate-400 focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex min-h-[250px] items-center justify-center">
            <div className="h-7 w-7 animate-spin rounded-full border-[3px] border-slate-200 border-t-blue-600" />
          </div>
        ) : error ? (
          <div className="flex min-h-[250px] flex-col items-center justify-center text-center">
            <AlertCircle className="h-6 w-6 text-red-400" />

            <p className="mt-3 text-[12px] font-semibold text-slate-700">
              Technician data unavailable
            </p>

            <p className="mt-1 text-[11px] text-slate-400">{error}</p>

            <button
              onClick={loadTechnicians}
              className="mt-4 rounded-lg border border-slate-200 px-4 py-2 text-[11px] font-semibold text-slate-600 hover:bg-slate-50"
            >
              Try again
            </button>
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex min-h-[250px] flex-col items-center justify-center">
            <UsersRound className="h-7 w-7 text-slate-300" />

            <p className="mt-3 text-[12px] font-semibold text-slate-700">
              No technicians found
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="border-b border-slate-100 bg-slate-50/80">
                <tr>
                  <TableHead>Technician</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Specialization</TableHead>
                  <TableHead>Availability</TableHead>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {filtered.map((technician) => (
                  <tr key={technician.id} className="hover:bg-slate-50/70">
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <Avatar name={technician.name} />

                        <div>
                          <p className="text-[12px] font-semibold text-slate-800">
                            {technician.name}
                          </p>

                          <p className="mt-0.5 text-[9.5px] text-slate-400">
                            Technician #{technician.id}
                          </p>
                        </div>
                      </div>
                    </td>

                    <td className="px-5 py-4 text-[11.5px] text-slate-500">
                      {technician.email || "—"}
                    </td>

                    <td className="px-5 py-4">
                      <span className="inline-flex items-center gap-1.5 rounded-md bg-slate-100 px-2.5 py-1 text-[10px] font-semibold text-slate-600">
                        <Wrench className="h-3 w-3" />

                        {technician.skill || "GENERAL"}
                      </span>
                    </td>

                    <td className="px-5 py-4">
                      <Availability available={technician.isAvailable} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}

function SummaryCard({ label, value, icon: Icon, green, amber }) {
  let style = "bg-blue-50 text-blue-600";

  if (green) {
    style = "bg-emerald-50 text-emerald-600";
  }

  if (amber) {
    style = "bg-amber-50 text-amber-600";
  }

  return (
    <div className="flex items-center justify-between rounded-xl border border-slate-200 bg-white p-4">
      <div>
        <p className="text-[10.5px] font-medium text-slate-400">{label}</p>

        <p className="mt-1 text-[23px] font-bold text-slate-900">{value}</p>
      </div>

      <div
        className={`flex h-9 w-9 items-center justify-center rounded-lg ${style}`}
      >
        <Icon className="h-4 w-4" />
      </div>
    </div>
  );
}

function Avatar({ name }) {
  const initials = name
    ? name
        .split(" ")
        .filter(Boolean)
        .slice(0, 2)
        .map((part) => part[0])
        .join("")
        .toUpperCase()
    : "T";

  return (
    <div className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white">
      {initials}
    </div>
  );
}

function Availability({ available }) {
  return available ? (
    <span className="inline-flex items-center gap-1.5 text-[10.5px] font-semibold text-emerald-700">
      <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
      Available
    </span>
  ) : (
    <span className="inline-flex items-center gap-1.5 text-[10.5px] font-semibold text-slate-500">
      <span className="h-1.5 w-1.5 rounded-full bg-slate-400" />
      Busy
    </span>
  );
}

function TableHead({ children }) {
  return (
    <th className="px-5 py-3 text-[9.5px] font-bold uppercase tracking-[0.1em] text-slate-400">
      {children}
    </th>
  );
}

export default TechniciansPage;
