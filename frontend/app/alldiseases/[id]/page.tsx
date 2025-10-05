"use client";
import { useParams } from "next/navigation";
import {Orals} from "../../../data/AllOrals";
import Image from "next/image";

export default function DiseasePage() {
  const { id } = useParams();
  const oral = Orals.find((o) => o.id === Number(Array.isArray(id) ? id[0] : id));

  if (!oral) {
    return (
      <div className="max-w-6xl mx-auto bg-[#00000085] rounded-xl shadow-lg p-8 mt-8">
        <h1 className="text-2xl font-bold text-red-600">Disease not found</h1>
        <p className="text-gray-600 mt-4">Requested ID: {id}</p>
        <p className="text-gray-600">Available IDs: {Orals.map(o => o.id).join(', ')}</p>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto rounded-xl shadow-lg p-8 mt-8">
      <button
        className="mb-6 px-4 py-2 bg-blue-700 text-white rounded hover:bg-blue-800 transition"
        onClick={() => window.history.back()}
      >
        الرجوع
      </button>
      <h1 className="text-4xl font-bold text-center mb-6 text-blue-900">{oral.title}</h1>
      <div className="flex justify-center mb-6">
      <Image
        src={oral.img[0]}
        alt={oral.title}
        width={520}
        height={320}
        priority
        className="rounded-lg shadow-md object-cover"
      />
      </div>
      <h2 className="text-xl font-semibold text-gray-800 mb-4">{oral.description}</h2>
      <h3 className="text-lg text-gray-600 mb-8">{oral.overview}</h3>

      <section className="mb-8">
      <h2 className="text-2xl font-bold text-blue-800 mb-4">Symptoms</h2>
      <h3 className="text-lg font-semibold text-gray-700 mb-2">
        {oral.symptoms.title}
      </h3>
      <ul className="space-y-4">
        {oral.symptoms.list.map((symptom, index) => (
        <li key={index} className="bg-blue-50 rounded-md p-4 shadow-sm">
          {typeof symptom === "object" ? (
          <>
            <h4 className="text-md font-bold text-blue-700">{symptom.type}</h4>
            <h5 className="text-gray-700">{symptom.desc}</h5>
          </>
          ) : (
          <h4 className="text-md font-bold text-blue-700">{symptom}</h4>
          )}
          {typeof symptom === "object" &&
          "dots" in symptom &&
          Array.isArray(symptom.dots) && (
            <ul className="list-disc ml-6 mt-2">
            {symptom.dots.map((dot, dotIndex) => (
              <li key={dotIndex} className="text-gray-600">
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
          <div key={idx} className="bg-yellow-50 rounded-md p-4 mb-4 shadow-sm">
            <h3 className="text-lg font-bold text-yellow-800">{when.title}</h3>
            <ul className="list-disc ml-6 mt-2">
            {when.list.map((item, itemIndex) => (
              <li key={itemIndex} className="text-gray-700">
              <h4>{item}</h4>
              </li>
            ))}
            </ul>
            {"note" in when && when.note && (
            <h5 className="text-sm text-yellow-700 mt-2">{when.note}</h5>
            )}
          </div>
          ))}
        </div>
        )}
      </section>

      <section className="mb-8">
      <h2 className="text-2xl font-bold text-blue-800 mb-4">Causes</h2>
      <h3 className="text-lg font-semibold text-gray-700 mb-2">
        {oral.causes.title}
      </h3>
      {oral.causes.triggers &&
        oral.causes.triggers.map((trigger, idx) => (
        <div key={idx} className="bg-green-50 rounded-md p-4 mb-4 shadow-sm">
          <h4 className="text-md font-bold text-green-700">{trigger.title}</h4>
          <ul className="list-disc ml-6 mt-2">
          {trigger.list.map((item, itemIndex) => (
            <li key={itemIndex} className="text-gray-700">
            <h5>{item}</h5>
            </li>
          ))}
          </ul>
        </div>
        ))}
      {oral.causes.conditions && (
        <div className="bg-green-100 rounded-md p-4 mb-4 shadow-sm">
        <h4 className="text-md font-bold text-green-800">
          {oral.causes.conditions.title}
        </h4>
        <ul className="list-disc ml-6 mt-2">
          {oral.causes.conditions.list.map((item, itemIndex) => (
          <li key={itemIndex} className="text-gray-700">
            <h5>{item}</h5>
          </li>
          ))}
        </ul>
        </div>
      )}
      {oral.causes.note && (
        <h5 className="text-sm text-green-700 mt-2">{oral.causes.note}</h5>
      )}
      </section>

      <section className="mb-8">
      <h2 className="text-2xl font-bold text-blue-800 mb-4">Risk Factors</h2>
      {typeof oral.riskFactors === "string" ? (
        <h3 className="text-lg font-semibold text-gray-700 mb-2">
        {oral.riskFactors}
        </h3>
      ) : oral.riskFactors && typeof oral.riskFactors === "object" ? (
        <div>
        <h3 className="text-lg font-semibold text-gray-700 mb-2">
          {oral.riskFactors.title}
        </h3>
        {oral.riskFactors.triggers &&
          oral.riskFactors.triggers.map((trigger, idx) => (
          <div key={idx} className="bg-red-50 rounded-md p-4 mb-4 shadow-sm">
            <h4 className="text-md font-bold text-red-700">{trigger.title}</h4>
            <ul className="list-disc ml-6 mt-2">
            {trigger.list.map((item, itemIndex) => (
              <li key={itemIndex} className="text-gray-700">
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
      <h2 className="text-2xl font-bold text-blue-800 mb-4">Prevention</h2>
      <h3 className="text-lg font-semibold text-gray-700 mb-2">
        {oral.prevention.title}
      </h3>
      <ul className="space-y-4">
        {oral.prevention.list.map((tip) => (
        <li key={tip.id} className="bg-purple-50 rounded-md p-4 shadow-sm">
          <h4 className="text-md font-bold text-purple-700">{tip.tip}</h4>
          <h5 className="text-gray-700">{tip.desc}</h5>
        </li>
        ))}
      </ul>
      </section>
    </div>
  );
}
