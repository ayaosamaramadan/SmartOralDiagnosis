import { useAuth } from "../../contexts/AuthContext";
import Prog from "./progress";
import { FaCheck } from "react-icons/fa6";
import { RxCross2 } from "react-icons/rx";


const CompletedOr = ({ form }: { form: any }) => {
  const { user} = useAuth();

  type Item = { num: string; title: string; desc: string; check: () => boolean };

    return (<>  <aside>
        <div className="w-full mt-6 rounded-md p-4 text-left shadow-sm">
        <div className=" items-center justify-between mb-7">
                <div className="mb-7">
                    <h3 className="text-sm font-semibold text-gray-900 dark:text-white mb-2">Complete your profile</h3>
                    <p className="text-xs text-gray-500 dark:text-gray-400">Fill the sections below to complete your profile</p>
                </div>
                {(() => {
                    const checks = [
                        !!(form.firstName?.trim()),
                        !!(form.lastName?.trim()),
                        !!(form.email?.trim()),
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
                {(() => {
                  const items: Array<Item | undefined> = [
                    { num: "1", title: "First name", desc: "Your given name", check: () => !!(form.firstName?.trim()) },
                    { num: "2", title: "Last name", desc: "Your family name", check: () => !!(form.lastName?.trim()) },
                    { num: "3", title: "Email", desc: "Primary contact email", check: () => !!(form.email?.trim()) },
                    { num: "4", title: "Location", desc: "City, state or coordinates", check: () => !!((form as any).location?.toString().trim()) },
                    { num: "5", title: "Phone", desc: "Mobile or contact number", check: () => !!(form.phoneNumber?.trim()) },
                    String(user?.role ?? "").toLowerCase() == "doctor" ? { num: "6", title: "Medical License", desc: "Your medical license number", check: () => !!(form.medicalLicense?.trim()) } : undefined,];
                  return items.filter((i): i is Item => Boolean(i)).map((item) => {
                    const ok = item.check();
                    return (
                        <li key={item.title} className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 rounded-full bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-100 flex items-center justify-center font-semibold">
                                    {item.num}
                                </div>
                                <div>
                                    <div className="text-sm font-medium text-gray-900 dark:text-white">{item.title}</div>
                                    <div className="text-xs text-gray-500 dark:text-gray-400">{item.desc}</div>
                                </div>
                            </div>
                            {ok ? (
                                <FaCheck className="text-green-600 dark:text-green-400" aria-hidden />
                            ) : (
                                <RxCross2 className="text-red-600 dark:text-red-400" aria-hidden />
                            )}
                        </li>
                    );
                  });
                })()}
            </ul>
        </div>
    </aside></>);
}

export default CompletedOr;