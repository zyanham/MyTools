import requests, pathlib
url="https://github.com/cszn/KAIR/releases/download/v1.0/ffdnet_color.pth"
out=pathlib.Path("model_zoo/ffdnet_color.pth")
out.parent.mkdir(parents=True, exist_ok=True)
r=requests.get(url, allow_redirects=True, timeout=300)
r.raise_for_status()
out.write_bytes(r.content)
print("saved:", out, "bytes=", out.stat().st_size)