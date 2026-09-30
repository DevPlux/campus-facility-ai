import { useEffect, useState } from "react";
import {
  AlertCircle,
  ArrowRight,
  BrainCircuit,
  CheckCircle2,
  ChevronRight,
  CircleDot,
  ClipboardList,
  Clock3,
  RefreshCw,
  Sparkles,
  UserCheck,
  Wrench,
} from "lucide-react";

import { useNavigate } from "react-router-dom";
import { getIssues } from "../services/issueService";
import StatusBadge from "../components/StatusBadge";

function DashboardPage() {
  const navigate = useNavigate();

  const [issues, setIssues] = useState([]);
  const [loading, setLoading] = useState(true);

  const [stats, setStats] = useState({
    total: 0,
    open: 0,
    pending: 0,
    completed: 0,
  });

  const fetchDashboard = async () => {
    try {
      setLoading(true);

      const data = await getIssues();
      const list = Array.isArray(data) ? data : [];

      setIssues(list);

      setStats({
        total: list.length,
        open: list.filter((issue) => issue.status === "OPEN").length,
        pending: list.filter((issue) => issue.status === "PENDING_APPROVAL")
          .length,
        completed: list.filter((issue) => issue.status === "COMPLETED").length,
      });
    } catch {
      setIssues([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const initialLoad = async () => {
      try {
        const data = await getIssues();

        if (cancelled) return;

        const list = Array.isArray(data) ? data : [];

        setIssues(list);

        setStats({
          total: list.length,
          open: list.filter((issue) => issue.status === "OPEN").length,
          pending: list.filter((issue) => issue.status === "PENDING_APPROVAL")
            .length,
          completed: list.filter((issue) => issue.status === "COMPLETED")
            .length,
        });
      } catch {
        if (!cancelled) {
          setIssues([]);
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

  const cards = [
    {
      title: "Total Issues",
      value: stats.total,
      subtitle: "All reported issues",
      icon: ClipboardList,
      iconClass: "bg-blue-50 text-blue-600",
    },
    {
      title: "Open Issues",
      value: stats.open,
      subtitle: "Awaiting analysis",
      icon: CircleDot,
      iconClass: "bg-violet-50 text-violet-600",
    },
    {
      title: "Pending Approval",
      value: stats.pending,
      subtitle: "Require manager action",
      icon: Clock3,
      iconClass: "bg-amber-50 text-amber-600",
    },
    {
      title: "Completed",
      value: stats.completed,
      subtitle: "Successfully resolved",
      icon: CheckCircle2,
      iconClass: "bg-emerald-50 text-emerald-600",
    },
  ];

  const recentIssues = issues.slice(0, 5);

  return (
    <div className="space-y-6">
      {/* Header */}
      <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-blue-600">
            Facility Operations
          </p>

          <h1 className="mt-1 text-[26px] font-bold tracking-tight text-slate-900">
            Management Dashboard
          </h1>

          <p className="mt-1 text-[13px] text-slate-500">
            Monitor facility issues, AI recommendations and resolution activity.
          </p>
        </div>

        <button
          onClick={fetchDashboard}
          disabled={loading}
          className="flex h-10 items-center gap-2 self-start rounded-lg border border-slate-200 bg-white px-4 text-[12px] font-semibold text-slate-600 shadow-sm transition hover:bg-slate-50 disabled:opacity-50"
        >
          <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          Refresh
        </button>
      </header>

      {/* Stats */}
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {cards.map(({ title, value, subtitle, icon: Icon, iconClass }) => (
          <div
            key={title}
            className="rounded-xl border border-slate-200 bg-white p-5 shadow-[0_1px_2px_rgba(15,23,42,0.03)]"
          >
            <div className="flex items-start justify-between">
              <div>
                <p className="text-[12px] font-medium text-slate-500">
                  {title}
                </p>

                <p className="mt-2 text-[28px] font-bold tracking-tight text-slate-900">
                  {loading ? "—" : value}
                </p>
              </div>

              <div
                className={`flex h-9 w-9 items-center justify-center rounded-lg ${iconClass}`}
              >
                <Icon className="h-[18px] w-[18px]" />
              </div>
            </div>

            <p className="mt-3 text-[10.5px] text-slate-400">{subtitle}</p>
          </div>
        ))}
      </section>

      {/* Main content */}
      <section className="grid gap-5 xl:grid-cols-[1.65fr_1fr]">
        {/* Operations */}
        <div className="rounded-xl border border-slate-200 bg-white">
          <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
            <div>
              <h2 className="text-[14px] font-bold text-slate-900">
                Facility Workflow
              </h2>

              <p className="mt-0.5 text-[11px] text-slate-400">
                End-to-end issue resolution process
              </p>
            </div>

            <span className="rounded-md bg-slate-100 px-2 py-1 text-[10px] font-semibold text-slate-500">
              5 stages
            </span>
          </div>

          <div className="p-5">
            <WorkflowItem
              icon={ClipboardList}
              title="Issue Reported"
              description="Reporter submits issue details and evidence."
              number="01"
              color="blue"
            />

            <WorkflowConnector />

            <WorkflowItem
              icon={BrainCircuit}
              title="AI Analysis"
              description="Issue category, priority and required skill are identified."
              number="02"
              color="violet"
            />

            <WorkflowConnector />

            <WorkflowItem
              icon={Sparkles}
              title="Technician Recommendation"
              description="AI recommends a suitable available technician."
              number="03"
              color="indigo"
            />

            <WorkflowConnector />

            <WorkflowItem
              icon={UserCheck}
              title="Manager Approval"
              description="Manager reviews and approves the proposed assignment."
              number="04"
              color="amber"
            />

            <WorkflowConnector />

            <WorkflowItem
              icon={Wrench}
              title="Issue Resolution"
              description="Technician resolves the issue and uploads completion evidence."
              number="05"
              color="emerald"
            />
          </div>
        </div>

        {/* AI Operations */}
        <div className="rounded-xl border border-slate-200 bg-white">
          <div className="border-b border-slate-100 px-5 py-4">
            <div className="flex items-center gap-2">
              <Sparkles className="h-4 w-4 text-violet-600" />

              <h2 className="text-[14px] font-bold text-slate-900">
                AI Operations
              </h2>
            </div>

            <p className="mt-1 text-[11px] text-slate-400">
              Intelligent workflow services
            </p>
          </div>

          <div className="space-y-3 p-5">
            <AgentItem
              icon={BrainCircuit}
              title="Issue Analysis Agent"
              description="Classifies issues and identifies priority and required technical skill."
              color="violet"
            />

            <AgentItem
              icon={UserCheck}
              title="Assignment Agent"
              description="Matches issue requirements with technician skill and availability."
              color="blue"
            />

            <div className="mt-4 flex items-center justify-between rounded-lg border border-emerald-100 bg-emerald-50/70 px-3.5 py-3">
              <div className="flex items-center gap-2">
                <span className="h-2 w-2 rounded-full bg-emerald-500" />

                <span className="text-[11px] font-semibold text-emerald-800">
                  AI services operational
                </span>
              </div>

              <CheckCircle2 className="h-4 w-4 text-emerald-600" />
            </div>
          </div>
        </div>
      </section>

      {/* Recent issues */}
      <section className="overflow-hidden rounded-xl border border-slate-200 bg-white">
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
          <div>
            <h2 className="text-[14px] font-bold text-slate-900">
              Recent Issues
            </h2>

            <p className="mt-0.5 text-[11px] text-slate-400">
              Latest facility reports
            </p>
          </div>

          <button
            onClick={() => navigate("/issues")}
            className="flex items-center gap-1 text-[11px] font-semibold text-blue-600 hover:text-blue-700"
          >
            View all
            <ArrowRight className="h-3.5 w-3.5" />
          </button>
        </div>

        {recentIssues.length === 0 ? (
          <div className="flex min-h-[150px] flex-col items-center justify-center px-5 text-center">
            <AlertCircle className="h-5 w-5 text-slate-300" />

            <p className="mt-2 text-[12px] font-medium text-slate-500">
              No issue data available
            </p>

            <p className="mt-1 text-[10.5px] text-slate-400">
              Issues will appear here when the backend is connected.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="bg-slate-50/70">
                <tr>
                  <TableHead>Issue</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Priority</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead />
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {recentIssues.map((issue) => (
                  <tr key={issue.id} className="hover:bg-slate-50/70">
                    <td className="px-5 py-3.5">
                      <p className="text-[12px] font-semibold text-slate-800">
                        {issue.title}
                      </p>

                      <p className="mt-0.5 text-[10px] text-slate-400">
                        #{issue.id}
                      </p>
                    </td>

                    <td className="px-5 py-3.5 text-[11.5px] text-slate-500">
                      {issue.location}
                    </td>

                    <td className="px-5 py-3.5 text-[11.5px] text-slate-500">
                      {issue.category || "Not analyzed"}
                    </td>

                    <td className="px-5 py-3.5 text-[11.5px] font-medium text-slate-600">
                      {issue.priority || "—"}
                    </td>

                    <td className="px-5 py-3.5">
                      <StatusBadge status={issue.status} />
                    </td>

                    <td className="px-5 py-3.5 text-right">
                      <button
                        onClick={() => navigate(`/issues/${issue.id}`)}
                        className="rounded-md p-1.5 text-slate-400 hover:bg-slate-100 hover:text-slate-700"
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
      </section>
    </div>
  );
}

function WorkflowItem({ icon: Icon, title, description, number, color }) {
  const colors = {
    blue: "bg-blue-50 text-blue-600",
    violet: "bg-violet-50 text-violet-600",
    indigo: "bg-indigo-50 text-indigo-600",
    amber: "bg-amber-50 text-amber-600",
    emerald: "bg-emerald-50 text-emerald-600",
  };

  return (
    <div className="flex items-center gap-4">
      <div
        className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${colors[color]}`}
      >
        <Icon className="h-[17px] w-[17px]" />
      </div>

      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between gap-3">
          <p className="text-[12px] font-semibold text-slate-800">{title}</p>

          <span className="text-[9px] font-bold tracking-widest text-slate-300">
            {number}
          </span>
        </div>

        <p className="mt-0.5 text-[10.5px] leading-4 text-slate-400">
          {description}
        </p>
      </div>
    </div>
  );
}

function WorkflowConnector() {
  return (
    <div className="ml-[17px] h-4 border-l border-dashed border-slate-200" />
  );
}

function AgentItem({ icon: Icon, title, description, color }) {
  const colorClass =
    color === "violet"
      ? "bg-violet-50 text-violet-600"
      : "bg-blue-50 text-blue-600";

  return (
    <div className="rounded-lg border border-slate-100 p-4">
      <div className="flex items-start gap-3">
        <div
          className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg ${colorClass}`}
        >
          <Icon className="h-[17px] w-[17px]" />
        </div>

        <div>
          <div className="flex items-center gap-2">
            <p className="text-[12px] font-semibold text-slate-800">{title}</p>

            <span className="rounded bg-emerald-50 px-1.5 py-0.5 text-[8.5px] font-bold uppercase text-emerald-600">
              Active
            </span>
          </div>

          <p className="mt-1.5 text-[10.5px] leading-[17px] text-slate-400">
            {description}
          </p>
        </div>
      </div>
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

export default DashboardPage;
