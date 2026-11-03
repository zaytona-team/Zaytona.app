"""Performance sampling with account A only (no second account needed):
  * REST latency per endpoint (warm, sequential, n per endpoint)
  * concurrency burst on the single eventlet worker
  * Socket.IO fan-out latency: REST mutation -> event on two sockets of A
Writes results/perf_a.json. Cleans up every item it creates.
"""
import json
import statistics as st
import sys
import threading
import time
from pathlib import Path

import requests
import socketio

HOST = "https://zaytona-app.onrender.com"
BASE = HOST + "/api/v1"
A_PHONE = "+966555455544"
QA_LIST, PERSONAL = sys.argv[1], sys.argv[2]
OUT = Path(__file__).parent / "results"
sys.stdout.reconfigure(encoding="utf-8")

s = requests.Session()
assert s.post(BASE + "/auth/login", json={"identifier": A_PHONE}, timeout=60).json()["otp_method"] == "dev-bypass"
tok = s.post(BASE + "/auth/otp/verify", json={"phone": A_PHONE, "token": "4444"}, timeout=60).json()
H = {"Authorization": f"Bearer {tok['access_token']}"}


def pct(vals, p):
    vals = sorted(vals)
    return round(vals[min(len(vals) - 1, max(0, int(round(p / 100 * len(vals))) - 1))], 1)


# ── REST latency ─────────────────────────────────────────────
rest = {}
for label, path in (("GET /auth/me", "/auth/me"), ("GET /groups", "/groups"),
                    ("GET /groups/{id}", f"/groups/{PERSONAL}"), ("GET /groups/{id}/lists", f"/groups/{PERSONAL}/lists"),
                    ("GET /lists/{id}", f"/lists/{QA_LIST}"), ("GET /lists/{id}/items", f"/lists/{QA_LIST}/items"),
                    ("GET /lists/{id}/history", f"/lists/{QA_LIST}/history"), ("GET /lists/{id}/trips", f"/lists/{QA_LIST}/trips"),
                    ("GET /lists/{id}/trips/active", f"/lists/{QA_LIST}/trips/active"),
                    ("GET /users/me/items", "/users/me/items"), ("GET /catalog/search?q=milk", "/catalog/search?q=milk"),
                    ("GET /categories", "/categories/"), ("GET /auth/avatars", "/auth/avatars")):
    ts = []
    for _ in range(15):
        t0 = time.perf_counter()
        r = s.get(BASE + path, headers=H, timeout=60)
        ts.append((time.perf_counter() - t0) * 1000)
        assert r.status_code == 200, (path, r.status_code, r.text[:200])
    rest[label] = {"n": 15, "p50": round(st.median(ts), 1), "p95": pct(ts, 95), "min": round(min(ts), 1),
                   "max": round(max(ts), 1), "bytes": len(r.content)}
    print(f"{label:30} p50={rest[label]['p50']:7} p95={rest[label]['p95']:7} max={rest[label]['max']:7} "
          f"body={rest[label]['bytes']}B")

# ── concurrency burst ────────────────────────────────────────
bursts = {}
for n in (5, 10, 20):
    lat = [0.0] * n
    codes = [0] * n

    def one(i):
        t0 = time.perf_counter()
        r = requests.get(BASE + f"/groups/{PERSONAL}/lists", headers=H, timeout=90)
        lat[i], codes[i] = (time.perf_counter() - t0) * 1000, r.status_code

    t0 = time.perf_counter()
    th = [threading.Thread(target=one, args=(i,)) for i in range(n)]
    [t.start() for t in th]
    [t.join() for t in th]
    wall = (time.perf_counter() - t0) * 1000
    bursts[n] = {"wall_ms": round(wall), "p50": round(st.median(lat)), "max": round(max(lat)),
                 "statuses": sorted(set(codes))}
    print(f"burst {n:2} parallel GET /groups/{{id}}/lists: wall={wall:.0f} ms p50={st.median(lat):.0f} "
          f"max={max(lat):.0f} statuses={sorted(set(codes))}")
    time.sleep(1)

# ── Socket.IO fan-out ────────────────────────────────────────
events, cv = [], threading.Condition()


def make_client(tag):
    c = socketio.Client(reconnection=False)

    @c.on("*")
    def _any(event, data=None):
        with cv:
            events.append((tag, event, time.perf_counter(), len(json.dumps(data, default=str)), data))
            cv.notify_all()
    t0 = time.perf_counter()
    c.connect(HOST, auth={"token": tok["access_token"]}, transports=["websocket"], wait_timeout=20)
    return c, round((time.perf_counter() - t0) * 1000, 1)


c1, h1 = make_client("S1")
c2, h2 = make_client("S2")
print(f"handshake S1={h1} ms S2={h2} ms")


def wait_for(tag, event, since, pred, timeout=8):
    end = time.perf_counter() + timeout
    with cv:
        while time.perf_counter() < end:
            for t, e, ts, size, d in events:
                if t == tag and e == event and ts >= since and pred(d or {}):
                    return ts, size
            cv.wait(0.2)
    return None, None


fan = []
for i in range(10):
    for step in ("add", "update", "purchase", "unpurchase", "delete"):
        t0 = time.perf_counter()
        if step == "add":
            r = s.post(BASE + f"/lists/{QA_LIST}/items", headers=H, json={"name": f"perf item {i}", "quantity": 1,
                                                                        "unit": "pcs"}, timeout=60)
            item = r.json()["list_item_id"]
            ev, pred = "item.added", (lambda d, item=item: d.get("item", {}).get("list_item_id") == item)
        elif step == "update":
            r = s.patch(BASE + f"/lists/{QA_LIST}/items/{item}", headers=H, json={"quantity": 2}, timeout=60)
            ev, pred = "item.updated", (lambda d, item=item: d.get("item", {}).get("list_item_id") == item)
        elif step == "purchase":
            r = s.patch(BASE + f"/lists/{QA_LIST}/items/{item}/purchase", headers=H, json={"is_bought": True}, timeout=60)
            ev, pred = "item.purchased", (lambda d, item=item: d.get("item", {}).get("list_item_id") == item)
        elif step == "unpurchase":
            r = s.patch(BASE + f"/lists/{QA_LIST}/items/{item}/purchase", headers=H, json={"is_bought": False}, timeout=60)
            ev, pred = "item.unpurchased", (lambda d, item=item: d.get("item", {}).get("list_item_id") == item)
        else:
            r = s.delete(BASE + f"/lists/{QA_LIST}/items/{item}", headers=H, timeout=60)
            ev, pred = "item.deleted", (lambda d, item=item: d.get("list_item_id") == item)
        t1 = time.perf_counter()
        for tag in ("S1", "S2"):
            ts, size = wait_for(tag, ev, t0, pred)
            fan.append({"round": i, "event": ev, "socket": tag, "http_status": r.status_code,
                        "http_ms": round((t1 - t0) * 1000, 1),
                        "event_ms_from_send": round((ts - t0) * 1000, 1) if ts else None,
                        "event_ms_after_response": round((ts - t1) * 1000, 1) if ts else None, "bytes": size})

c1.disconnect()
c2.disconnect()
by_event = {}
for ev in ("item.added", "item.updated", "item.purchased", "item.unpurchased", "item.deleted"):
    rows = [f for f in fan if f["event"] == ev]
    got = [f["event_ms_from_send"] for f in rows if f["event_ms_from_send"] is not None]
    http = [f["http_ms"] for f in rows]
    by_event[ev] = {"delivered": f"{len(got)}/{len(rows)}", "p50_from_send": round(st.median(got), 1) if got else None,
                    "p95_from_send": pct(got, 95) if got else None, "http_p50": round(st.median(http), 1),
                    "bytes": max(f["bytes"] or 0 for f in rows)}
    print(f"{ev:18} delivered {by_event[ev]['delivered']}  event p50={by_event[ev]['p50_from_send']} ms "
          f"p95={by_event[ev]['p95_from_send']} ms  (HTTP p50 {by_event[ev]['http_p50']} ms) payload≈{by_event[ev]['bytes']}B")

json.dump({"rest": rest, "bursts": bursts, "handshake_ms": [h1, h2], "fanout_by_event": by_event, "fanout_raw": fan},
          open(OUT / "perf_a.json", "w"), indent=1)
