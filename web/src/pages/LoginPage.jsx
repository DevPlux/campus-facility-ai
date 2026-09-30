import { useState } from "react";
import { useNavigate } from "react-router-dom";

import {
  AlertCircle,
  ArrowRight,
  BrainCircuit,
  Building2,
  CheckCircle2,
  Eye,
  EyeOff,
  Lock,
  Mail,
  ShieldCheck,
  Sparkles,
  Wrench,
} from "lucide-react";

import { login, saveAuth } from "../services/authService";

function LoginPage() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");

  const [password, setPassword] = useState("");

  const [showPassword, setShowPassword] = useState(false);

  const [error, setError] = useState("");

  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");

    if (!email.trim() || !password) {
      setError("Please enter your email and password.");
      return;
    }

    try {
      setLoading(true);

      const data = await login(email.trim(), password);

      if (data.user?.role !== "MANAGER") {
        setError("This dashboard is only available for managers.");
        return;
      }

      saveAuth(data.token, data.user);

      navigate("/dashboard", {
        replace: true,
      });
    } catch {
      setError("Login failed. Please check your credentials.");
    } finally {
      setLoading(false);
    }
  };

  const handleDevLogin = () => {
    saveAuth("temporary-dev-token", {
      id: 1,
      name: "Test Manager",
      email: "manager@test.com",
      role: "MANAGER",
    });

    navigate("/dashboard", {
      replace: true,
    });
  };

  return (
    <div className="grid min-h-screen bg-[#F7F8FA] lg:grid-cols-[1.05fr_0.95fr]">
      {/* LEFT */}
      <section className="relative hidden overflow-hidden bg-slate-950 lg:flex lg:flex-col lg:justify-between lg:p-12 xl:p-16">
        {/* subtle decoration */}
        <div className="absolute right-[-120px] top-[-120px] h-[360px] w-[360px] rounded-full bg-blue-600/10 blur-3xl" />

        <div className="relative flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-600">
            <Building2 className="h-5 w-5 text-white" />
          </div>

          <div>
            <p className="text-[14px] font-bold text-white">
              Campus Facility AI
            </p>

            <p className="text-[9.5px] font-bold uppercase tracking-[0.15em] text-slate-500">
              Management Platform
            </p>
          </div>
        </div>

        <div className="relative max-w-xl">
          <div className="mb-6 inline-flex items-center gap-2 rounded-md border border-white/10 bg-white/5 px-3 py-1.5 text-[10px] font-semibold text-slate-300">
            <Sparkles className="h-3.5 w-3.5 text-blue-400" />
            AI-powered facility operations
          </div>

          <h1 className="max-w-lg text-[42px] font-bold leading-[1.1] tracking-[-0.03em] text-white">
            Manage campus facilities with greater clarity.
          </h1>

          <p className="mt-5 max-w-lg text-[14px] leading-7 text-slate-400">
            A centralized platform for reporting, analyzing, assigning and
            resolving facility issues through an intelligent, auditable
            workflow.
          </p>

          <div className="mt-10 grid gap-3">
            <Feature
              icon={BrainCircuit}
              title="AI Issue Analysis"
              description="Automatically classify facility reports and identify required skills."
            />

            <Feature
              icon={ShieldCheck}
              title="Controlled Approval"
              description="Managers remain in control of AI-generated technician recommendations."
            />

            <Feature
              icon={Wrench}
              title="Resolution Tracking"
              description="Track each issue from initial report through technician completion."
            />
          </div>
        </div>

        <div className="relative flex items-center gap-2 text-[10.5px] text-slate-500">
          <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
          Facility Management Administration
        </div>
      </section>

      {/* RIGHT */}
      <section className="flex min-h-screen items-center justify-center px-5 py-10 sm:px-10">
        <div className="w-full max-w-[420px]">
          {/* mobile brand */}
          <div className="mb-10 flex items-center gap-3 lg:hidden">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-600">
              <Building2 className="h-5 w-5 text-white" />
            </div>

            <div>
              <p className="text-[14px] font-bold text-slate-900">
                Campus Facility AI
              </p>

              <p className="text-[9.5px] font-bold uppercase tracking-wider text-slate-400">
                Management Platform
              </p>
            </div>
          </div>

          <div className="mb-8">
            <p className="text-[10px] font-bold uppercase tracking-[0.15em] text-blue-600">
              Manager Console
            </p>

            <h2 className="mt-2 text-[28px] font-bold tracking-tight text-slate-900">
              Welcome back
            </h2>

            <p className="mt-2 text-[13px] text-slate-500">
              Sign in to access the facility management dashboard.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <Field label="Email address" icon={Mail}>
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                placeholder="manager@example.com"
                className="h-11 w-full rounded-lg border border-slate-200 bg-white pl-10 pr-3 text-[12.5px] text-slate-800 outline-none placeholder:text-slate-400 focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
              />
            </Field>

            <Field label="Password" icon={Lock}>
              <input
                type={showPassword ? "text" : "password"}
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                placeholder="Enter your password"
                className="h-11 w-full rounded-lg border border-slate-200 bg-white pl-10 pr-10 text-[12.5px] text-slate-800 outline-none placeholder:text-slate-400 focus:border-blue-400 focus:ring-2 focus:ring-blue-100"
              />

              <button
                type="button"
                onClick={() => setShowPassword((value) => !value)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
              >
                {showPassword ? (
                  <EyeOff className="h-4 w-4" />
                ) : (
                  <Eye className="h-4 w-4" />
                )}
              </button>
            </Field>

            {error && (
              <div className="flex gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-3 text-[11px] font-medium text-red-700">
                <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" />
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="flex h-11 w-full items-center justify-center gap-2 rounded-lg bg-blue-600 text-[12.5px] font-semibold text-white transition hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? (
                <>
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
                  Signing in...
                </>
              ) : (
                <>
                  Sign in
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </button>

            {/* TEMPORARY */}
            <button
              type="button"
              onClick={handleDevLogin}
              className="h-11 w-full rounded-lg border border-slate-200 bg-white text-[11.5px] font-semibold text-slate-600 transition hover:bg-slate-50"
            >
              Continue as Manager (Development)
            </button>
          </form>

          <p className="mt-8 text-center text-[10px] text-slate-400">
            Campus Facility Issue Management System
          </p>
        </div>
      </section>
    </div>
  );
}

function Feature({ icon: Icon, title, description }) {
  return (
    <div className="flex items-start gap-4 rounded-lg border border-white/[0.07] bg-white/[0.035] p-4">
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-white/[0.07]">
        <Icon className="h-[17px] w-[17px] text-blue-400" />
      </div>

      <div>
        <p className="text-[12px] font-semibold text-slate-200">{title}</p>

        <p className="mt-1 text-[10.5px] leading-5 text-slate-500">
          {description}
        </p>
      </div>
    </div>
  );
}

function Field({ label, icon: Icon, children }) {
  return (
    <div>
      <label className="mb-2 block text-[11px] font-semibold text-slate-600">
        {label}
      </label>

      <div className="relative">
        <Icon className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />

        {children}
      </div>
    </div>
  );
}

export default LoginPage;
