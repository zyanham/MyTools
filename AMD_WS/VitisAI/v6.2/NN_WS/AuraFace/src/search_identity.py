#!/usr/bin/env python3

import argparse
import csv
import json
import os
from pathlib import Path
from typing import List

import numpy as np
import onnxruntime as ort

from infer_file2file import l2_normalize, list_images, preprocess


def create_session(args) -> ort.InferenceSession:
    if args.device == "cpu":
        return ort.InferenceSession(args.model, providers=["CPUExecutionProvider"])

    provider_options = {
        "config_file": os.path.abspath(args.config),
        "cache_dir": os.path.abspath(args.cache_dir),
        "cache_key": args.cache_key,
        "target": "VAIML",
    }
    return ort.InferenceSession(
        args.model,
        providers=["VitisAIExecutionProvider"],
        provider_options=[provider_options],
    )


def embed(session: ort.InferenceSession, image_path: Path, img_size: int, rgb: bool) -> np.ndarray:
    input_name = session.get_inputs()[0].name
    tensor = preprocess(image_path, img_size, rgb)
    embedding = session.run(None, {input_name: tensor})[0]
    return l2_normalize(np.asarray(embedding, dtype=np.float32))[0]


def same_file(a: Path, b: Path) -> bool:
    try:
        return a.resolve() == b.resolve()
    except OSError:
        return a.absolute() == b.absolute()


def main() -> None:
    parser = argparse.ArgumentParser(description="Search AuraFace embeddings for images similar to a query face.")
    parser.add_argument("--model", default="models/auraface.onnx")
    parser.add_argument("--query", default="../Dataset/HumanFaces/matz01.jpg")
    parser.add_argument("--gallery", default="../Dataset/HumanFaces")
    parser.add_argument("--output_dir", default="results/search_auraface")
    parser.add_argument("--device", choices=["cpu", "npu"], default="cpu")
    parser.add_argument("--config", default="vitisai_config.json")
    parser.add_argument("--cache_dir", default="my_cache_dir")
    parser.add_argument("--cache_key", default="auraface_fp32_bf16")
    parser.add_argument("--img_size", type=int, default=112)
    parser.add_argument("--top_k", type=int, default=20)
    parser.add_argument("--threshold", type=float, default=0.30)
    parser.add_argument("--rgb", action="store_true", help="Use RGB channel order instead of InsightFace-style BGR.")
    args = parser.parse_args()

    query = Path(args.query)
    gallery = Path(args.gallery)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    if not query.is_file():
        raise FileNotFoundError(f"Query image not found: {query}")

    gallery_images = [p for p in list_images(gallery) if not same_file(p, query)]
    if not gallery_images:
        raise FileNotFoundError(f"No gallery images found: {gallery}")

    session = create_session(args)
    query_embedding = embed(session, query, args.img_size, args.rgb)

    rows = []
    for image_path in gallery_images:
        candidate_embedding = embed(session, image_path, args.img_size, args.rgb)
        similarity = float(np.dot(query_embedding, candidate_embedding))
        rows.append({
            "file": str(image_path),
            "name": image_path.name,
            "similarity": similarity,
            "above_threshold": similarity >= args.threshold,
        })

    rows.sort(key=lambda item: item["similarity"], reverse=True)
    for index, row in enumerate(rows, start=1):
        row["rank"] = index

    top_rows = rows[: args.top_k]
    threshold_rows = [row for row in rows if row["above_threshold"]]

    csv_path = output_dir / "search_results.csv"
    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["rank", "name", "file", "similarity", "above_threshold"])
        writer.writeheader()
        writer.writerows(rows)

    report = {
        "device": args.device,
        "model": args.model,
        "query": str(query),
        "gallery": str(gallery),
        "gallery_count": len(gallery_images),
        "threshold": args.threshold,
        "top_k": args.top_k,
        "matches_above_threshold": threshold_rows,
        "top_results": top_rows,
    }
    json_path = output_dir / "search_results.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    summary_path = output_dir / "search_summary.txt"
    with open(summary_path, "w", encoding="utf-8") as f:
        f.write(f"device: {args.device}\n")
        f.write(f"query: {query}\n")
        f.write(f"gallery: {gallery}\n")
        f.write(f"gallery_count: {len(gallery_images)}\n")
        f.write(f"threshold: {args.threshold}\n")
        f.write("\nthreshold_matches:\n")
        if threshold_rows:
            for row in threshold_rows:
                f.write(f"{row['rank']:03d} {row['similarity']:.6f} {row['name']}\n")
        else:
            f.write("none\n")
        f.write("\ntop_results:\n")
        for row in top_rows:
            f.write(f"{row['rank']:03d} {row['similarity']:.6f} {row['name']}\n")

    print(f"query: {query.name}")
    print(f"gallery images: {len(gallery_images)}")
    print(f"threshold: {args.threshold}")
    if threshold_rows:
        print("matches above threshold:")
        for row in threshold_rows[: args.top_k]:
            print(f"  #{row['rank']:03d} {row['similarity']:.6f} {row['name']}")
    else:
        print("matches above threshold: none")
    print("top results:")
    for row in top_rows:
        print(f"  #{row['rank']:03d} {row['similarity']:.6f} {row['name']}")
    print(f"wrote {csv_path}")
    print(f"wrote {json_path}")
    print(f"wrote {summary_path}")


if __name__ == "__main__":
    main()
