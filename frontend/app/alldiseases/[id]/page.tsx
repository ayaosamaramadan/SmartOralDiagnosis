"use client";
import { useParams } from "next/navigation";
import { Orals } from "../../../data/AllOrals";
import Image from "next/image";
import { IoMdArrowRoundBack } from "react-icons/io";

import { BsFillCalendarDateFill } from "react-icons/bs";


export default function DiseasePage() {
  const { id } = useParams();
  const oral = Orals.find((o) => o.id === Number(Array.isArray(id) ? id[0] : id));

  if (!oral) {
    return (
      <div className="leading-tight space-y-3 max-w-6xl mx-auto rounded-xl shadow-lg p-8 mt-8">
        <h1 className="text-2xl font-bold text-red-600">Disease not found</h1>
        <p className="text-gray-600 mt-4">Requested ID: {id}</p>
        <p className="text-gray-600">Available IDs: {Orals.map(o => o.id).join(', ')}</p>
      </div>
    );
  }

  return (
  <div className="max-w-7xl mx-auto rounded-xl shadow-lg p-8 mt-20 bg-gradient-to-br from-[#23252641] via-[#35353594] to-[#24242442]">
    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
      <div>
        <button
          title="Go Back"
          className="mb-6 py-2 flex items-center gap-2 text-blue-700 font-semibold rounded hover:underline focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
          onClick={() => window.history.back()}
        >
          <IoMdArrowRoundBack className="text-2xl" />
          Diseases & Conditions
        </button>
        <h1 className="text-5xl font-extrabold mb-6 text-white drop-shadow-lg">{oral.title}</h1>
        <button
          title="Request an Appointment"
          className="mb-6 px-4 py-2 flex items-center gap-2 text-green-700 font-semibold rounded hover:underline focus:outline-none focus:ring-2 focus:ring-green-400 transition"
          aria-label="Request an Appointment"
        >
          <BsFillCalendarDateFill className="text-xl" />
          <span>Request an Appointment</span>
        </button>
        <div className="flex mb-6">
          <Image
            src={oral.img[0]}
            alt={oral.title}
            width={300}
            height={120}
            priority
            className="rounded-lg shadow-md"
          />
        </div>
        <h3 className="text-xl text-gray-100 mb-8 leading-relaxed">{oral.overview}</h3>

        <section className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-4">Symptoms</h2>
          <h3 className="text-lg font-semibold text-blue-200 mb-2">
            {oral.symptoms.title}
          </h3>
          <ul className="space-y-4">
            {oral.symptoms.list.map((symptom, index) => (
              <li key={index} className="rounded-md p-4 shadow-sm bg-gray-800/80">
                {typeof symptom === "object" ? (
                  <>
                    <h4 className="text-md font-bold text-blue-100">{symptom.type}</h4>
                    <h5 className="text-gray-100 leading-relaxed">{symptom.desc}</h5>
                  </>
                ) : (
                  <h4 className="text-md font-bold text-blue-100">{symptom}</h4>
                )}
                {typeof symptom === "object" &&
                  "dots" in symptom &&
                  Array.isArray(symptom.dots) && (
                    <ul className="list-disc ml-6 mt-2">
                      {symptom.dots.map((dot, dotIndex) => (
                        <li key={dotIndex} className="text-gray-100 leading-relaxed">
                          <h6>{dot}</h6>
                        </li>
                      ))}
                    </ul>
                  )}
              </li>
            ))}
          </ul>
          {oral.symptoms.WhenSeeDoctor &&
            Array.isArray(oral.symptoms.WhenSeeDoctor) && (
              <div className="mt-6">
                {oral.symptoms.WhenSeeDoctor.map((when, idx) => (
                  <div key={idx} className="rounded-md p-4 mb-4 shadow-sm bg-gray-800/80">
                    <h3 className="text-lg font-bold text-blue-100">{when.title}</h3>
                    <ul className="list-disc ml-6 mt-2">
                      {when.list.map((item, itemIndex) => (
                        <li key={itemIndex} className="text-gray-100 leading-relaxed">
                          <h4>{item}</h4>
                        </li>
                      ))}
                    </ul>
                    {"note" in when && when.note && (
                      <h5 className="text-sm text-gray-400 mt-2">{when.note}</h5>
                    )}
                  </div>
                ))}
              </div>
            )}
        </section>

        <section className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-4">Causes</h2>
          <h3 className="text-lg font-semibold text-blue-200 mb-2">
            {oral.causes.title}
          </h3>
          {oral.causes.triggers &&
            oral.causes.triggers.map((trigger, idx) => (
              <div key={idx} className="rounded-md p-4 mb-4 shadow-sm bg-gray-800/80">
                <h4 className="text-md font-bold text-blue-100">{trigger.title}</h4>
                {"list" in trigger && Array.isArray(trigger.list) && (
                  <ul className="list-disc ml-6 mt-2">
                    {trigger.list.map((item: string, itemIndex: number) => (
                      <li key={itemIndex} className="text-gray-100 leading-relaxed">
                        <h5>{item}</h5>
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            ))}
          {oral.causes.conditions && (
            <div className="rounded-md p-4 mb-4 shadow-sm bg-gray-800/80">
              <h4 className="text-md font-bold text-blue-100">
                {oral.causes.conditions.title}
              </h4>
              {Array.isArray(oral.causes.conditions.list) && (
                <ul className="list-disc ml-6 mt-2">
                  {oral.causes.conditions.list.map((item, itemIndex) => (
                    <li key={itemIndex} className="text-gray-100 leading-relaxed">
                      <h5>{item}</h5>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}
          {oral.causes.note && (
            <h5 className="text-sm text-gray-400 mt-2">{oral.causes.note}</h5>
          )}
        </section>

        <section className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-4">Risk Factors</h2>
          {typeof oral.riskFactors === "string" ? (
            <h3 className="text-lg font-semibold text-blue-200 mb-2">
              {oral.riskFactors}
            </h3>
          ) : oral.riskFactors && typeof oral.riskFactors === "object" ? (
            <div>
              <h3 className="text-lg font-semibold text-blue-200 mb-2">
                {oral.riskFactors.title}
              </h3>
              {oral.riskFactors.triggers &&
                oral.riskFactors.triggers.map((trigger, idx) => (
                  <div key={idx} className="rounded-md p-4 mb-4 shadow-sm bg-gray-800/80">
                    <h4 className="text-md font-bold text-blue-100">{trigger.title}</h4>
                    <ul className="list-disc ml-6 mt-2">
                      {trigger.list.map((item, itemIndex) => (
                        <li key={itemIndex} className="text-gray-100 leading-relaxed">
                          <h5>{item}</h5>
                        </li>
                      ))}
                    </ul>
                  </div>
                ))}
            </div>
          ) : null}
        </section>

        <section className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-4">Prevention</h2>
          <h3 className="text-lg font-semibold text-blue-200 mb-2">
            {oral.prevention.title}
          </h3>
          <ul className="space-y-4">
            {oral.prevention.list.map((tip) => (
              <li key={tip.id} className="rounded-md p-4 shadow-sm bg-gray-800/80">
                <h4 className="text-md font-bold text-blue-100">{tip.tip}</h4>
                <h5 className="text-gray-100 leading-relaxed">{tip.desc}</h5>
              </li>
            ))}
          </ul>
        </section>
       
      </div>

      <div className="flex flex-col justify-center items-center bg-gray-900/90 rounded-lg p-6 h-fit max-h-[320px] self-start shadow-lg">
        <h2 className="text-2xl font-bold text-blue-100 mb-4">Did you know?</h2>
        <p className="text-gray-100 text-lg text-center leading-relaxed">
          Oral health is a vital part of your overall well-being. Regular checkups and good hygiene can help prevent many diseases. Stay informed and take care of your smile!
        </p>
      </div>
    </div>
  </div>

  );
}
