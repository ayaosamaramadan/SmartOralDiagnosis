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
    <main className="flex min-h-[calc(100vh-4rem)] items-center justify-center bg-slate-50 px-6 py-16 dark:bg-slate-950">
      <div className="flex w-full max-w-2xl flex-col items-center rounded-2xl border border-slate-200 bg-white p-10 text-center dark:border-slate-800 dark:bg-slate-900">

        {/* Icon */}
        <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-xl bg-sky-100 dark:bg-sky-950">
          <span className="text-xl font-medium text-sky-700 dark:text-sky-300">
            {title.charAt(0).toUpperCase()}
          </span>
        </div>

        {/* Eyebrow */}
        <p className="text-xs font-medium uppercase tracking-widest text-slate-400 dark:text-slate-500">
          Section unavailable
        </p>

        {/* Title */}
        <h1 className="mt-2 text-2xl font-medium text-slate-900 dark:text-slate-50">
          {title}
        </h1>

        {/* Description */}
        <p className="mt-3 max-w-md text-sm leading-7 text-slate-500 dark:text-slate-400">
          {description}
        </p>

        {/* Actions */}
        <div className="mt-8 flex flex-wrap justify-center gap-2">
          <Link
            href={backHref}
            className="inline-flex items-center gap-2 rounded-full bg-slate-900 px-5 py-2.5 text-sm font-medium text-white transition hover:bg-slate-700 dark:bg-slate-100 dark:text-slate-900 dark:hover:bg-slate-300"
          >
            {backLabel}
          </Link>
          <Link
            href="/scan"
            className="inline-flex items-center gap-2 rounded-full border border-sky-200 bg-transparent px-5 py-2.5 text-sm font-medium text-sky-700 transition hover:bg-sky-50 dark:border-sky-800 dark:text-sky-400 dark:hover:bg-sky-950"
          >
            Go to scanner
          </Link>
        </div>

      </div>
    </main>
  );
}