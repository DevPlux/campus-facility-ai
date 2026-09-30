function LoadingSpinner({ label = "Loading...", fullScreen = false }) {
  const content = (
    <div className="flex flex-col items-center justify-center gap-3">
      <div className="h-7 w-7 animate-spin rounded-full border-[3px] border-slate-200 border-t-blue-600" />

      <p className="text-[12px] font-medium text-slate-500">{label}</p>
    </div>
  );

  if (fullScreen) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#F7F8FA]">
        {content}
      </div>
    );
  }

  return (
    <div className="flex min-h-[220px] items-center justify-center">
      {content}
    </div>
  );
}

export default LoadingSpinner;
