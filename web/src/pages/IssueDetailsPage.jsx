import { useEffect, useState } from "react";

import { useNavigate, useParams } from "react-router-dom";

import {
  AlertCircle,
  ArrowLeft,
  BrainCircuit,
  Building2,
  CalendarDays,
  Camera,
  Check,
  CheckCircle2,
  ClipboardList,
  MapPin,
  RefreshCw,
  Sparkles,
  UserCheck,
  Wrench,
  X,
} from "lucide-react";

import StatusBadge from "../components/StatusBadge";

import { getIssueById } from "../services/issueService";

import {
  approveAssignment,
  rejectAssignment,
} from "../services/assignmentService";

function IssueDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [issue, setIssue] = useState(null);

  const [loading, setLoading] = useState(true);

  const [actionLoading, setActionLoading] = useState("");

  const [error, setError] = useState("");

  const [message, setMessage] = useState("");

  const loadIssue = async () => {
    try {
      setLoading(true);
      setError("");

      const data = await getIssueById(id);

      setIssue(data);
    } catch {
      setError("Unable to load issue details.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let cancelled = false;

    const initialLoad = async () => {
      try {
        const data = await getIssueById(id);

        if (!cancelled) {
          setIssue(data);
        }
      } catch {
        if (!cancelled) {
          setError("Unable to load issue details.");
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
  }, [id]);

  const runAction = async (actionName, action, successMessage) => {
    try {
      setActionLoading(actionName);
      setError("");
      setMessage("");

      await action();

      setMessage(successMessage);

      await loadIssue();
    } catch (err) {
      setError(
        err.response?.data?.message ||
          "The requested action could not be completed.",
      );
    } finally {
      setActionLoading("");
    }
  };

  const handleApprove = () => {
    if (!issue?.assignmentId) return;

    runAction(
      "approve",
      () => approveAssignment(issue.assignmentId),
      "Technician assignment approved.",
    );
  };

  const handleReject = () => {
    if (!issue?.assignmentId) return;

    runAction(
      "reject",
      () => rejectAssignment(issue.assignmentId),
      "Technician assignment rejected.",
    );
  };

  if (loading && !issue) {
    return (
      <div className="flex min-h-[500px] items-center justify-center">
        <div className="h-7 w-7 animate-spin rounded-full border-[3px] border-slate-200 border-t-blue-600" />
      </div>
    );
  }

  if (!issue) {
    return (
      <div className="flex min-h-[400px] flex-col items-center justify-center">
        <AlertCircle className="h-7 w-7 text-red-400" />

        <p className="mt-3 text-[13px] font-semibold text-slate-700">
          Issue unavailable
        </p>

        <button
          onClick={loadIssue}
          className="mt-4 rounded-lg border border-slate-200 px-4 py-2 text-[11px] font-semibold text-slate-600"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Back */}
      <button
        onClick={() => navigate("/issues")}
        className="flex items-center gap-2 text-[11.5px] font-semibold text-slate-500 transition hover:text-slate-900"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to issues
      </button>

      {/* Header */}
      <header className="flex flex-col gap-4 border-b border-slate-200 pb-6 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-[26px] font-bold tracking-tight text-slate-900">
              {issue.title}
            </h1>

            <StatusBadge status={issue.status} />
          </div>

          <p className="mt-2 text-[12px] text-slate-400">Issue #{issue.id}</p>
        </div>

        <button
          onClick={loadIssue}
          disabled={loading}
          className="flex h-9 items-center gap-2 self-start rounded-lg border border-slate-200 bg-white px-3.5 text-[11px] font-semibold text-slate-600 hover:bg-slate-50"
        >
          <RefreshCw className="h-3.5 w-3.5" />
          Refresh
        </button>
      </header>

      {/* Messages */}
      {message && (
        <div className="flex items-center gap-2 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-[11.5px] font-medium text-emerald-700">
          <CheckCircle2 className="h-4 w-4" />
          {message}
        </div>
      )}

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[11.5px] font-medium text-red-700">
          <AlertCircle className="h-4 w-4" />
          {error}
        </div>
      )}

      {/* Metadata */}
      <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Metadata icon={MapPin} label="Location" value={issue.location} />

        <Metadata
          icon={ClipboardList}
          label="Category"
          value={issue.category || "Not analyzed"}
        />

        <Metadata
          icon={AlertCircle}
          label="Priority"
          value={issue.priority || "Not analyzed"}
        />

        <Metadata
          icon={Wrench}
          label="Required Skill"
          value={issue.requiredSkill || "Not analyzed"}
        />
      </section>

      <div className="grid gap-5 xl:grid-cols-[1.6fr_1fr]">
        {/* LEFT */}
        <div className="space-y-5">
          {/* Details */}
          <Card title="Issue Information" icon={Building2}>
            <p className="text-[10px] font-bold uppercase tracking-[0.1em] text-slate-400">
              Description
            </p>

            <p className="mt-2 whitespace-pre-wrap text-[12.5px] leading-6 text-slate-600">
              {issue.description}
            </p>

            {issue.createdAt && (
              <div className="mt-5 flex items-center gap-2 border-t border-slate-100 pt-4 text-[10.5px] text-slate-400">
                <CalendarDays className="h-3.5 w-3.5" />
                Reported {new Date(issue.createdAt).toLocaleString()}
              </div>
            )}
          </Card>

          {/* Evidence */}
          <Card title="Issue Evidence" icon={Camera}>
            <div className="grid gap-4 md:grid-cols-2">
              <EvidenceImage label="Before" imageUrl={issue.beforeImageUrl} />

              <EvidenceImage label="After" imageUrl={issue.afterImageUrl} />
            </div>
          </Card>

          {/* AI */}
          <Card title="AI Issue Analysis" icon={BrainCircuit}>
            {issue.aiSummary ? (
              <div className="rounded-lg border border-violet-100 bg-violet-50/60 p-4">
                <div className="flex items-center gap-2">
                  <Sparkles className="h-4 w-4 text-violet-600" />

                  <p className="text-[10px] font-bold uppercase tracking-[0.1em] text-violet-700">
                    AI Summary
                  </p>
                </div>

                <p className="mt-2 text-[12px] leading-6 text-slate-600">
                  {issue.aiSummary}
                </p>
              </div>
            ) : (
              <p className="text-[11.5px] text-slate-400">
                No AI analysis is available for this issue yet.
              </p>
            )}
          </Card>
        </div>

        {/* RIGHT */}
        <div className="space-y-5">
          {/* Assignment */}
          <Card title="Technician Assignment" icon={UserCheck}>
            <p className="text-[11.5px] leading-5 text-slate-500">
              The assignment agent matches the issue requirements with available
              technicians.
            </p>

            {issue.assignmentId && (
              <div className="mt-4 rounded-lg border border-slate-200 p-4">
                <p className="text-[9.5px] font-bold uppercase tracking-[0.1em] text-slate-400">
                  Recommended Technician
                </p>

                <div className="mt-3 flex items-center gap-3">
                  <div className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-900 text-[10px] font-bold text-white">
                    <Wrench className="h-4 w-4" />
                  </div>

                  <div>
                    <p className="text-[12px] font-semibold text-slate-800">
                      {issue.technicianName ||
                        `Technician #${issue.technicianId}`}
                    </p>

                    <p className="text-[10px] text-slate-400">
                      AI recommendation
                    </p>
                  </div>
                </div>

                {issue.recommendationReason && (
                  <div className="mt-4 rounded-md bg-slate-50 p-3">
                    <p className="text-[9px] font-bold uppercase tracking-wider text-slate-400">
                      Recommendation reason
                    </p>

                    <p className="mt-1.5 text-[10.5px] leading-5 text-slate-500">
                      {issue.recommendationReason}
                    </p>
                  </div>
                )}

                {issue.status === "PENDING_APPROVAL" && (
                  <div className="mt-4 grid grid-cols-2 gap-2">
                    <button
                      onClick={handleReject}
                      disabled={actionLoading !== ""}
                      className="flex h-9 items-center justify-center gap-1.5 rounded-lg border border-red-200 bg-white text-[10.5px] font-semibold text-red-600 hover:bg-red-50"
                    >
                      <X className="h-3.5 w-3.5" />
                      Reject
                    </button>

                    <button
                      onClick={handleApprove}
                      disabled={actionLoading !== ""}
                      className="flex h-9 items-center justify-center gap-1.5 rounded-lg bg-emerald-600 text-[10.5px] font-semibold text-white hover:bg-emerald-700"
                    >
                      <Check className="h-3.5 w-3.5" />
                      Approve
                    </button>
                  </div>
                )}
              </div>
            )}
          </Card>

          {/* Workflow status */}
          <Card title="Workflow Status" icon={ClipboardList}>
            <WorkflowStatus currentStatus={issue.status} />
          </Card>
        </div>
      </div>
    </div>
  );
}

function Card({ title, icon: Icon, action, children }) {
  return (
    <section className="rounded-xl border border-slate-200 bg-white">
      <div className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
        <div className="flex items-center gap-2.5">
          <Icon className="h-4 w-4 text-slate-500" />

          <h2 className="text-[13px] font-bold text-slate-800">{title}</h2>
        </div>

        {action}
      </div>

      <div className="p-5">{children}</div>
    </section>
  );
}

function Metadata({ icon: Icon, label, value }) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-4">
      <div className="flex items-center gap-2 text-slate-400">
        <Icon className="h-3.5 w-3.5" />

        <span className="text-[9.5px] font-bold uppercase tracking-[0.1em]">
          {label}
        </span>
      </div>

      <p className="mt-2 text-[12px] font-semibold text-slate-700">
        {value || "—"}
      </p>
    </div>
  );
}

function EvidenceImage({ label, imageUrl }) {
  return (
    <div>
      <p className="mb-2 text-[10px] font-semibold text-slate-500">
        {label} Photo
      </p>

      {imageUrl ? (
        <img
          src={imageUrl}
          alt={`${label} evidence`}
          className="h-52 w-full rounded-lg border border-slate-200 object-cover"
        />
      ) : (
        <div className="flex h-52 flex-col items-center justify-center rounded-lg border border-dashed border-slate-200 bg-slate-50">
          <Camera className="h-6 w-6 text-slate-300" />

          <p className="mt-2 text-[10.5px] text-slate-400">
            No photo available
          </p>
        </div>
      )}
    </div>
  );
}

function WorkflowStatus({ currentStatus }) {
  const stages = [
    "OPEN",
    "ANALYZED",
    "PENDING_APPROVAL",
    "ASSIGNED",
    "IN_PROGRESS",
    "COMPLETED",
  ];

  const currentIndex = stages.indexOf(currentStatus);

  return (
    <div className="space-y-0">
      {stages.map((stage, index) => {
        const reached = currentIndex >= index;

        return (
          <div key={stage} className="flex gap-3">
            <div className="flex flex-col items-center">
              <div
                className={`flex h-5 w-5 items-center justify-center rounded-full border ${
                  reached
                    ? "border-blue-600 bg-blue-600"
                    : "border-slate-200 bg-white"
                }`}
              >
                {reached && <Check className="h-3 w-3 text-white" />}
              </div>

              {index < stages.length - 1 && (
                <div
                  className={`h-7 w-px ${
                    currentIndex > index ? "bg-blue-300" : "bg-slate-200"
                  }`}
                />
              )}
            </div>

            <p
              className={`pt-0.5 text-[10.5px] font-medium ${
                reached ? "text-slate-700" : "text-slate-400"
              }`}
            >
              {stage.replaceAll("_", " ")}
            </p>
          </div>
        );
      })}
    </div>
  );
}

export default IssueDetailsPage;
