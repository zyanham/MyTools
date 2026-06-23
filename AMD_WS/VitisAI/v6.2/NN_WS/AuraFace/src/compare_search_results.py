#!/usr/bin/env python3

import argparse
import csv
import json
from pathlib import Path


def read_rows(path: Path) -> list[dict]:
    with open(path, "r", encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare AuraFace CPU and NPU search ranking CSVs.")
    parser.add_argument("--cpu_csv", default="results/search_host_matz01/search_results.csv")
    parser.add_argument("--npu_csv", default="results/search_npu_matz01/search_results.csv")
    parser.add_argument("--output_dir", default="results/search_compare_matz01")
    parser.add_argument("--top_k", type=int, default=20)
    args = parser.parse_args()

    cpu_rows = read_rows(Path(args.cpu_csv))
    npu_rows = read_rows(Path(args.npu_csv))
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    npu_by_name = {row["name"]: row for row in npu_rows}
    comparisons = []
    for cpu_row in cpu_rows[: args.top_k]:
        npu_row = npu_by_name.get(cpu_row["name"])
        if npu_row is None:
            continue
        cpu_similarity = float(cpu_row["similarity"])
        npu_similarity = float(npu_row["similarity"])
        comparisons.append({
            "name": cpu_row["name"],
            "cpu_rank": int(cpu_row["rank"]),
            "npu_rank": int(npu_row["rank"]),
            "cpu_similarity": cpu_similarity,
            "npu_similarity": npu_similarity,
            "abs_delta": abs(cpu_similarity - npu_similarity),
        })

    max_delta = max((row["abs_delta"] for row in comparisons), default=0.0)
    report = {
        "cpu_csv": args.cpu_csv,
        "npu_csv": args.npu_csv,
        "top_k": args.top_k,
        "top_k_name_order_equal": [row["name"] for row in cpu_rows[: args.top_k]] == [row["name"] for row in npu_rows[: args.top_k]],
        "max_abs_similarity_delta_in_compared_rows": max_delta,
        "comparisons": comparisons,
    }

    json_path = output_dir / "cpu_npu_search_compare.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    txt_path = output_dir / "cpu_npu_search_compare.txt"
    with open(txt_path, "w", encoding="utf-8") as f:
        f.write(f"top_k_name_order_equal: {report['top_k_name_order_equal']}\n")
        f.write(f"max_abs_similarity_delta: {max_delta:.9f}\n")
        f.write("\ncompared_top_results:\n")
        for row in comparisons:
            f.write(
                f"{row['cpu_rank']:03d}/{row['npu_rank']:03d} "
                f"cpu={row['cpu_similarity']:.6f} "
                f"npu={row['npu_similarity']:.6f} "
                f"delta={row['abs_delta']:.9f} "
                f"{row['name']}\n"
            )

    print(f"top_k_name_order_equal: {report['top_k_name_order_equal']}")
    print(f"max_abs_similarity_delta: {max_delta:.9f}")
    print(f"wrote {json_path}")
    print(f"wrote {txt_path}")


if __name__ == "__main__":
    main()
