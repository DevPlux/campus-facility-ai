const statusStyles = {
  OPEN: "border-blue-200 bg-blue-50 text-blue-700",
  ANALYZED: "border-violet-200 bg-violet-50 text-violet-700",
  PENDING_APPROVAL: "border-amber-200 bg-amber-50 text-amber-700",
  ASSIGNED: "border-indigo-200 bg-indigo-50 text-indigo-700",
  IN_PROGRESS: "border-cyan-200 bg-cyan-50 text-cyan-700",
  COMPLETED: "border-emerald-200 bg-emerald-50 text-emerald-700",
  REJECTED: "border-red-200 bg-red-50 text-red-700",
};

const dotStyles = {
  OPEN: "bg-blue-500",
  ANALYZED: "bg-violet-500",
  PENDING_APPROVAL: "bg-amber-500",
  ASSIGNED: "bg-indigo-500",
  IN_PROGRESS: "bg-cyan-500",
  COMPLETED: "bg-emerald-500",
  REJECTED: "bg-red-500",
};

function StatusBadge({ status }) {
  const style =
    statusStyles[status] ?? "border-slate-200 bg-slate-50 text-slate-600";

  const dot = dotStyles[status] ?? "bg-slate-400";

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-[10.5px] font-semibold ${style}`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${dot}`} />

      {status?.replaceAll("_", " ") ?? "UNKNOWN"}
    </span>
  );
}

export default StatusBadge;
