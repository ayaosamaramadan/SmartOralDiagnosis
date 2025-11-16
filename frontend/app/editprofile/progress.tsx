const Prog = ( { percent, r, c, dashOffset }: { percent: number; r: number; c: number; dashOffset: number } ) => {
    return (<>
    <div className="w-full flex items-center justify-center">
        <div className="w-48 h-48 mx-auto">
            <div className="relative w-full h-full">
                <svg className="w-full h-full" viewBox="0 0 48 48" fill="none" role="img" aria-label={`Profile completion ${percent}%`}>
                    <circle
                        cx="24"
                        cy="24"
                        r={r}
                        strokeWidth="4"
                        stroke="currentColor"
                        className="text-gray-200 dark:text-gray-700"
                    />
                    <circle
                        cx="24"
                        cy="24"
                        r={r}
                        strokeWidth="4"
                        stroke="currentColor"
                        className="text-green-500 dark:text-green-400"
                        strokeLinecap="round"
                        strokeDasharray={c}
                        strokeDashoffset={dashOffset}
                        transform="rotate(-90 24 24)"
                    />
                </svg>

                <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <div className="text-2xl font-semibold text-gray-900 dark:text-white">{percent}%</div>
                </div>
            </div>
        </div>
    </div>
              </>  );
}
 
export default Prog;