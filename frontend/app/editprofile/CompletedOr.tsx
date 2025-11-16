import Prog from "./progress";
import { FaCheck } from "react-icons/fa6";
import { RxCross2 } from "react-icons/rx";


const CompletedOr = ({ form }: { form: any }) => {
    return (<>  <aside>
        <div className="w-full mt-6 bg-white dark:bg-gray-800 rounded-md p-4 text-left shadow-sm">
            <div className=" items-center justify-between mb-3">
                <div>
                    <h3 className="text-sm font-semibold text-gray-900 dark:text-white">Complete your profile</h3>
                    <p className="text-xs text-gray-500 dark:text-gray-400">Fill the sections below to complete your profile</p>
                </div>
                {(() => {
                    const checks = [
                        !!(form.firstName?.trim()),
                        !!(form.lastName?.trim()),
                        !!(form.email?.trim()),
                        !!((form as any).password?.trim()),
                        !!((form as any).location?.toString().trim()),
                        !!(form.phoneNumber?.trim()),
                    ];
                    const completed = checks.filter(Boolean).length;
                    const total = checks.length;
                    const percent = Math.round((completed / total) * 100);
                    const r = 18;
                    const c = 2 * Math.PI * r;
                    const dashOffset = c * (1 - percent / 100);

                    return (
                        <>
                            <Prog percent={percent} r={r} c={c} dashOffset={dashOffset} />
                        </>
                    );
                })()}
            </div>

                <ul className="flex flex-col gap-3">
                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">1</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">First name</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">Your given name</div>
                        </div>
                    </div>
                    {!!(form.firstName?.trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>

                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">2</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">Last name</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">Your family name</div>
                        </div>
                    </div>
                    {!!(form.lastName?.trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>

                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">3</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">Email</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">Primary contact email</div>
                        </div>
                    </div>
                    {!!(form.email?.trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>

                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">4</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">Password</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">Set an account password</div>
                        </div>
                    </div>
                    {!!((form as any).password?.trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>

                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">5</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">Location</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">City, state or coordinates</div>
                        </div>
                    </div>
                    {!!((form as any).location?.toString().trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>

                <li className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-primary-100 text-primary-700 dark:bg-primary-900 dark:text-primary-200 flex items-center justify-center font-semibold">6</div>
                        <div>
                            <div className="text-sm font-medium text-gray-900 dark:text-white">Phone</div>
                            <div className="text-xs text-gray-500 dark:text-gray-400">Mobile or contact number</div>
                        </div>
                    </div>
                    {!!(form.phoneNumber?.trim()) ? (
                        <FaCheck className="text-green-500"/>

                    ) : (
                        <RxCross2 className="text-red-500"/>
                    )}
                </li>
            </ul>
        </div>
    </aside></>);
}

export default CompletedOr;