const Prog = ( { percent, r, c, dashOffset }: { percent: number; r: number; c: number; dashOffset: number } ) => {
    return (<>
       <div className="w-16">
              <div className="relative w-16 h-16">
                <svg className="w-16 h-16" viewBox="0 0 48 48" fill="none" aria-hidden>
                <circle
                  cx="24"
                  cy="24"
                  r={r}
                  strokeWidth="4"
                  stroke="#e5e7eb"
                  className="dark:stroke-gray-700"
                />
                <circle
                  cx="24"
                  cy="24"
                  r={r}
                  strokeWidth="4"
                  stroke="currentColor"
                  className="text-primary-600"
                  strokeLinecap="round"
                  strokeDasharray={c}
                  strokeDashoffset={dashOffset}
                  transform="rotate(-90 24 24)"
                />
                </svg>

                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div className="text-sm font-semibold">{percent}%</div>
                </div>
              </div>
              </div>
              </>  );
}
 
export default Prog;