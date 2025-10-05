"use client";
import {Oral} from "../../../types/oralTypes";
import { useParams } from "next/navigation";
import {Orals} from "../../../data/AllOrals";
import Image from "next/image";

export default function DiseasePage() {
  const { id } = useParams();
  const oral = Orals.find((o) => o.id === Number(Array.isArray(id) ? id[0] : id));

  if (!oral) {
    return <div>Disease not found</div>;
  }

  return (
    <div>
      <h1 style={{ color: "#1976d2" }}>{oral.title}</h1>
      <div>
        <Image
          src={oral.img[0]}
          alt={oral.title}
          width={520}
          height={320}
          priority
        />
      </div>
      <h2 style={{ color: "#388e3c" }}>{oral.description}</h2>
      <h3 style={{ color: "#6d4c41" }}>{oral.overview}</h3>
      <h2 style={{ color: "#d32f2f" }}>Symptoms</h2>
      <h3 style={{ color: "#fbc02d" }}>{oral.symptoms.title}</h3>
      <ul>
        {oral.symptoms.list.map((symptom, index) => (
          <li key={index}>
            <h4 style={{ color: "#0288d1" }}>{symptom.type}</h4>
            <h5 style={{ color: "#7b1fa2" }}>{symptom.desc}</h5>
            {"dots" in symptom && Array.isArray(symptom.dots) && (
              <ul>
                {symptom.dots.map((dot, dotIndex) => (
                  <li key={dotIndex}><h6 style={{ color: "#c2185b" }}>{dot}</h6></li>
                ))}
              </ul>
            )}
          </li>
        ))}
      </ul>
      {oral.symptoms.WhenSeeDoctor && Array.isArray(oral.symptoms.WhenSeeDoctor) && (
        <div>
          {oral.symptoms.WhenSeeDoctor.map((when, idx) => (
            <div key={idx}>
              <h3 style={{ color: "#f57c00" }}>{when.title}</h3>
              <ul>
                {when.list.map((item, itemIndex) => (
                  <li key={itemIndex}><h4 style={{ color: "#388e3c" }}>{item}</h4></li>
                ))}
              </ul>
              {"note" in when && when.note && (
                <h5 style={{ color: "#455a64" }}>{when.note}</h5>
              )}
            </div>
          ))}
        </div>
      )}
      <h2 style={{ color: "#1976d2" }}>Causes</h2>
      <h3 style={{ color: "#c62828" }}>{oral.causes.title}</h3>
      {oral.causes.triggers && oral.causes.triggers.map((trigger, idx) => (
        <div key={idx}>
          <h4 style={{ color: "#ad1457" }}>{trigger.title}</h4>
          <ul>
            {trigger.list.map((item, itemIndex) => (
              <li key={itemIndex}><h5 style={{ color: "#6d4c41" }}>{item}</h5></li>
            ))}
          </ul>
        </div>
      ))}
      {oral.causes.conditions && (
        <div>
          <h4 style={{ color: "#0288d1" }}>{oral.causes.conditions.title}</h4>
          <ul>
            {oral.causes.conditions.list.map((item, itemIndex) => (
              <li key={itemIndex}><h5 style={{ color: "#7b1fa2" }}>{item}</h5></li>
            ))}
          </ul>
        </div>
      )}
      {oral.causes.note && (
        <h5 style={{ color: "#455a64" }}>{oral.causes.note}</h5>
      )}
      <h2 style={{ color: "#d32f2f" }}>Risk Factors</h2>
      {typeof oral.riskFactors === "string" ? (
        <h3 style={{ color: "#fbc02d" }}>{oral.riskFactors}</h3>
      ) : oral.riskFactors && typeof oral.riskFactors === "object" ? (
        <div>
          <h3 style={{ color: "#fbc02d" }}>{oral.riskFactors.title}</h3>
          {oral.riskFactors.triggers && oral.riskFactors.triggers.map((trigger, idx) => (
            <div key={idx}>
              <h4 style={{ color: "#0288d1" }}>{trigger.title}</h4>
              <ul>
                {trigger.list.map((item, itemIndex) => (
                  <li key={itemIndex}><h5 style={{ color: "#7b1fa2" }}>{item}</h5></li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      ) : null}
      <h2 style={{ color: "#388e3c" }}>Prevention</h2>
      <h3 style={{ color: "#1976d2" }}>{oral.prevention.title}</h3>
      <ul>
        {oral.prevention.list.map((tip) => (
          <li key={tip.id}>
            <h4 style={{ color: "#ad1457" }}>{tip.tip}</h4>
            <h5 style={{ color: "#6d4c41" }}>{tip.desc}</h5>
          </li>
        ))}
      </ul>
    </div>
  );
}
