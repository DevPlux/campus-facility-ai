import { useEffect, useMemo, useState } from "react";

import { useNavigate } from "react-router-dom";

import {
  AlertCircle,
  ChevronRight,
  ClipboardList,
  Filter,
  RefreshCw,
  Search,
} from "lucide-react";

import StatusBadge from "../components/StatusBadge";
import { getIssues } from "../services/issueService";

const statuses = [
  "ALL",
  "OPEN",
  "ANALYZED",
  "PENDING_APPROVAL",
  "ASSIGNED",
  "IN_PROGRESS",
  "COMPLETED",
  "REJECTED",
];

function IssuesPage() {
  const navigate = useNavigate();

  const [issues, setIssues] = useState([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const [loading, setLoading] = useState(true);

  const [error, setError] = useState("");

  const loadIssues = async () => {
    try {
      setLoading(true);
      setError("");

      const data = await getIssues();

      setIssues(Array.isArray(data) ? data : []);
    } catch {
      setError("Unable to load facility issues.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const initialLoad = async () => {
      try {
        const data = await getIssues();

        if (!cancelled) {
          setIssues(Array.isArray(data) ? data : []);
        }
      } catch {
        if (!cancelled) {
          setError("Unable to load facility issues.");
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

  const filteredIssues = useMemo(() => {
    const value = search.trim().toLowerCase();

    return issues.filter((issue) => {
      const statusMatch =
        statusFilter === "ALL" || issue.status === statusFilter;

      const searchMatch =
        !value ||
        issue.title?.toLowerCase().includes(value) ||
        issue.location?.toLowerCase().includes(value) ||
        issue.category?.toLowerCase().includes(value);

      return statusMatch && searchMatch;
    });
  }, [issues, search, statusFilter]);

  return (
    <div className="space-y-6">
      {/* Header */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-blue-600">
            Facility Management
          </p>

          <h1 className="mt-1 text-[26px] font-bold tracking-tight text-slate-900">
            Issues
          </h1>

          <p className="mt-1 text-[13px] text-slate-500">
            Review and manage reported campus facility issues.
          </p>
        </div>

        <button
          onClick={loadIssues}
          disabled={loading}
          className="flex h-10 items-center gap-2 self-start rounded-lg border border-slate-200 bg-white px-4 text-[12px] font-semibold text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:opacity-50"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </button>
      </header>

      {/* Toolbar */}
      <div className="flex flex-col gap-3 rounded-xl border border-slate-200 bg-white p-3 sm:flex-row">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />

          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search issues by title, location or category..."
            className="h-10 w-full rounded-lg border border-slate-200 bg-white pl-10 pr-4 text-[12px] text-slate-700 outline-none transition placeholder:text-slate-400 focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
          />
        </div>

        <div className="relative">
          <Filter className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-slate-400" />

          <select
            value={statusFilter}
            onChange={(event) => setStatusFilter(event.target.value)}
            className="h-10 min-w-[190px] appearance-none rounded-lg border border-slate-200 bg-white pl-9 pr-8 text-[12px] font-medium text-slate-600 outline-none focus:border-blue-400"
          >
            {statuses.map((status) => (
              <option key={status} value={status}>
                {status === "ALL"
                  ? "All statuses"
                  : status.replaceAll("_", " ")}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
          <div className="flex items-center gap-2.5">
            <ClipboardList className="h-4 w-4 text-slate-500" />

            <div>
              <h2 className="text-[13px] font-bold text-slate-800">
                Facility Issues
              </h2>

              <p className="text-[10px] text-slate-400">
                {filteredIssues.length} records
              </p>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="flex min-h-[250px] items-center justify-center">
            <div className="h-7 w-7 animate-spin rounded-full border-[3px] border-slate-200 border-t-blue-600" />
          </div>
        ) : error ? (
          <ErrorState message={error} retry={loadIssues} />
        ) : filteredIssues.length === 0 ? (
          <EmptyState />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="border-b border-slate-100 bg-slate-50/80">
                <tr>
                  <TableHead>Issue</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Priority</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Reported</TableHead>
                  <TableHead />
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {filteredIssues.map((issue) => (
                  <tr
                    key={issue.id}
                    className="group transition hover:bg-slate-50/70"
                  >
                    <td className="px-5 py-4">
                      <p className="text-[12.5px] font-semibold text-slate-800">
                        {issue.title}
                      </p>

                      <p className="mt-0.5 text-[10px] text-slate-400">
                        Issue #{issue.id}
                      </p>
                    </td>

                    <td className="px-5 py-4 text-[11.5px] text-slate-500">
                      {issue.location}
                    </td>

                    <td className="px-5 py-4">
                      <span className="text-[11px] font-medium text-slate-600">
                        {issue.category || "Not analyzed"}
                      </span>
                    </td>

                    <td className="px-5 py-4">
                      <PriorityBadge priority={issue.priority} />
                    </td>

                    <td className="px-5 py-4">
                      <StatusBadge status={issue.status} />
                    </td>

                    <td className="px-5 py-4 text-[10.5px] text-slate-400">
                      {issue.createdAt
                        ? new Date(issue.createdAt).toLocaleDateString()
                        : "—"}
                    </td>

                    <td className="px-5 py-4 text-right">
                      <button
                        onClick={() => navigate(`/issues/${issue.id}`)}
                        className="inline-flex h-8 w-8 items-center justify-center rounded-md text-slate-400 transition hover:bg-slate-100 hover:text-blue-600"
                        aria-label="View issue"
                      >
                        <ChevronRight className="h-4 w-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

function PriorityBadge({ priority }) {
  if (!priority) {
    return <span className="text-[11px] text-slate-400">—</span>;
  }

  const styles = {
    HIGH: "bg-red-50 text-red-700 border-red-100",
    MEDIUM: "bg-amber-50 text-amber-700 border-amber-100",
    LOW: "bg-emerald-50 text-emerald-700 border-emerald-100",
  };

  return (
    <span
      className={`inline-flex rounded-md border px-2 py-1 text-[9.5px] font-bold ${
        styles[priority] ?? "border-slate-200 bg-slate-50 text-slate-600"
      }`}
    >
      {priority}
    </span>
  );
}

function ErrorState({ message, retry }) {
  return (
    <div className="flex min-h-[250px] flex-col items-center justify-center p-6 text-center">
      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-50">
        <AlertCircle className="h-5 w-5 text-red-500" />
      </div>

      <p className="mt-3 text-[12px] font-semibold text-slate-700">
        Unable to retrieve issues
      </p>

      <p className="mt-1 text-[11px] text-slate-400">{message}</p>

      <button
        onClick={retry}
        className="mt-4 rounded-lg border border-slate-200 bg-white px-4 py-2 text-[11px] font-semibold text-slate-600 hover:bg-slate-50"
      >
        Try again
      </button>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="flex min-h-[250px] flex-col items-center justify-center p-6 text-center">
      <ClipboardList className="h-7 w-7 text-slate-300" />

      <p className="mt-3 text-[12px] font-semibold text-slate-700">
        No issues found
      </p>

      <p className="mt-1 text-[11px] text-slate-400">
        No facility issues match the selected filters.
      </p>
    </div>
  );
}

function TableHead({ children }) {
  return (
    <th className="px-5 py-3 text-[9.5px] font-bold uppercase tracking-[0.1em] text-slate-400">
      {children}
    </th>
  );
}

export default IssuesPage;
