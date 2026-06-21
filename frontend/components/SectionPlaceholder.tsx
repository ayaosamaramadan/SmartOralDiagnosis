import Link from "next/link";

type SectionPlaceholderProps = {
  title: string;
  description: string;
  backHref?: string;
  backLabel?: string;
};

export default function SectionPlaceholder({
  title,
  description,
  backHref = "/",
  backLabel = "Back to home",
}: SectionPlaceholderProps) {
  return (
    <main className="min-h-[calc(100vh-4rem)] bg-[linear-gradient(180deg,#f8fbff_0%,#ffffff_45%,#eef7ff_100%)] px-6 py-16">
      <div className="mx-auto flex w-full max-w-4xl flex-col items-center justify-center rounded-3xl border border-slate-200/80 bg-white/85 p-8 text-center shadow-[0_24px_80px_rgba(15,23,42,0.08)] backdrop-blur">
        <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-sky-500 to-blue-600 text-white shadow-lg">
          <span className="text-xl font-bold">{title.charAt(0).toUpperCase()}</span>
        </div>

        <p className="text-sm font-semibold uppercase tracking-[0.32em] text-sky-700">
          Section unavailable
        </p>
        <h1 className="mt-3 text-3xl font-bold text-slate-900 md:text-4xl">{title}</h1>
        <p className="mt-4 max-w-2xl text-base leading-7 text-slate-600">{description}</p>

        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <Link
            href={backHref}
            className="inline-flex items-center justify-center rounded-full bg-slate-900 px-6 py-3 text-sm font-semibold text-white transition hover:bg-slate-700"
          >
            {backLabel}
          </Link>
          <Link
            href="/scan"
            className="inline-flex items-center justify-center rounded-full border border-sky-200 bg-sky-50 px-6 py-3 text-sm font-semibold text-sky-900 transition hover:bg-sky-100"
          >
            Go to scanner
          </Link>
        </div>
      </div>
    </main>
  );
}