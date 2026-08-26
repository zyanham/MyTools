import json
from pathlib import Path

cands = list(Path(".").rglob("*report*.json"))

if not cands:
    print("[NG] report json not found")
    raise SystemExit(1)

for p in cands:
    print("\n[INFO]", p)
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        print("[SKIP]", e)
        continue

    for item in data.get("deviceStat", []):
        print(item.get("name"), "nodes =", item.get("nodeNum"))
        ops = item.get("supportedOpType", [])
        if ops:
            print("  ops:", ops[:30])