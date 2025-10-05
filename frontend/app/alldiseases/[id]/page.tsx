"use client";
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
      <h1>{oral.title}</h1>
      <Image src={oral.img[0]} alt={oral.title} width={500} height={300} />
      <p>{oral.description}</p>
    </div>
  );
}
