"""Turn the app's Dio LogInterceptor output (adb logcat, tag flutter) into
per-request rows: device time, method, endpoint template, status, client-side
latency in ms. Usage: parse_flutter_log.py <log> [<log> ...] -> JSON on stdout."""
import json
import re
import sys
from datetime import datetime

UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
LINE = re.compile(r"^(\d\d-\d\d \d\d:\d\d:\d\d\.\d{3}) I/flutter \(\s*\d+\): ?(.*)$")
BASE = "https://zaytona-app.onrender.com/api/v1"


def template(uri):
    path = uri.replace(BASE, "").split("?")[0]
    path = UUID.sub("{id}", path)
    path = re.sub(r"/devices/[^/]+$", "/devices/{token}", path)
    return path or "/"


def parse(paths):
    rows = []
    for p in paths:
        block, pending = None, {}
        for raw in open(p, encoding="utf-8", errors="replace"):
            m = LINE.match(raw.rstrip("\n"))
            if not m:
                continue
            ts, msg = datetime.strptime("2026-" + m.group(1), "%Y-%m-%d %H:%M:%S.%f"), m.group(2)
            if msg.startswith("*** Request ***"):
                block = {"kind": "req", "t": ts}
            elif msg.startswith("*** Response ***") or msg.startswith("*** DioException ***"):
                block = {"kind": "res", "t": ts}
            elif block and msg.startswith("uri: "):
                block["uri"] = msg[5:].strip()
                if block["kind"] == "res":
                    q = pending.get(block["uri"])
                    if q:
                        req = q.pop(0)
                        block["req"] = req
            elif block and msg.startswith("method: ") and block["kind"] == "req":
                block["method"] = msg[8:].strip()
                pending.setdefault(block["uri"], []).append(block)
            elif block and msg.startswith("statusCode: ") and block["kind"] == "res" and "req" in block:
                req = block["req"]
                rows.append({
                    "device_log": p.split("\\")[-1].split("/")[-1],
                    "at": req["t"].strftime("%H:%M:%S"),
                    "method": req.get("method", "?"),
                    "endpoint": template(block["uri"]),
                    "status": int(msg[12:].strip() or 0),
                    "ms": round((block["t"] - req["t"]).total_seconds() * 1000),
                })
                block = None
    return rows


if __name__ == "__main__":
    print(json.dumps(parse(sys.argv[1:]), indent=1))
