"""Zaytona end-to-end QA harness — REST + Socket.IO + DB, against the live
Render deployment, driven by the two whitelisted test accounts.

Roles exercised: individual (A's personal group), group admin (A in a fresh
QA group), group member (B in that group), outsider (B vs A's personal group).

Every request/response, every socket event and every DB check is recorded to
results/*.json + results/api_log.txt for the QA report.
"""
import io
import json
import struct
import sys
import threading
import time
import uuid
import zlib
from datetime import datetime, timezone
from pathlib import Path
from statistics import median

import psycopg2
import requests
import socketio
from dotenv import dotenv_values

HOST = "https://zaytona-app.onrender.com"
BASE = HOST + "/api/v1"
OTP = "4444"
A_PHONE, B_PHONE = "+966555455544", "+966555455545"
UNKNOWN_PHONE = "+966500000009"  # verified absent from users before the run
ENV = Path(r"C:\Users\mmhd7\Downloads\Zaytona.app\zaytona\zaytona_api\.env")
OUT = Path(__file__).parent / "results"
OUT.mkdir(exist_ok=True)
sys.stdout.reconfigure(encoding="utf-8")

RUN_TAG = datetime.now().strftime("%Y-%m-%d %H:%M")
RESULTS, EVENTS, DBCHECKS, PERF = [], [], [], {}
LOG = open(OUT / "api_log.txt", "w", encoding="utf-8")


def now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds")


def log(line):
    LOG.write(line + "\n")
    LOG.flush()
    print(line, flush=True)


# ── DB (read-only) ────────────────────────────────────────────
def _dsn():
    url = dotenv_values(ENV, interpolate=False)["DATABASE_URL"]
    return url.replace("postgresql+psycopg2://", "postgresql://", 1)


def db(sql, params=None):
    conn = psycopg2.connect(_dsn(), connect_timeout=15)
    try:
        conn.set_session(readonly=True)
        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
        conn.rollback()
        return rows
    finally:
        conn.close()


def db_check(cid, title, sql, params, predicate, expect_desc):
    try:
        rows = db(sql, params)
        ok = bool(predicate(rows))
        actual = rows
    except Exception as e:  # noqa: BLE001
        ok, actual = False, f"ERROR {e}"
    rec = {"id": cid, "title": title, "expect": expect_desc, "actual": str(actual)[:400], "ok": ok}
    DBCHECKS.append(rec)
    log(f"  [DB {'PASS' if ok else 'FAIL'}] {cid} {title} -> {str(actual)[:200]}")
    return rows if not isinstance(actual, str) else None


# ── HTTP ──────────────────────────────────────────────────────
class User:
    def __init__(self, label, phone):
        self.label, self.phone = label, phone
        self.s = requests.Session()
        self.access = self.refresh = self.user_id = None
        self.first_access = None
        self.sock = None


def call(cid, area, role, title, user, method, path, *, json_body=None, expect=None,
         token="access", files=None, finding=None, raw=False):
    """One recorded API call. `expect` = int or tuple of acceptable statuses."""
    headers = {}
    tok = None
    if user is not None:
        tok = {"access": user.access, "refresh": user.refresh, "none": None}.get(token, token)
    if tok:
        headers["Authorization"] = f"Bearer {tok}"
    sess = user.s if user is not None else requests
    url = BASE + path
    t0 = time.perf_counter()
    try:
        r = sess.request(method, url, json=json_body, headers=headers, files=files, timeout=90)
        t1 = time.perf_counter()
        status = r.status_code
        try:
            body = r.json()
        except ValueError:
            body = r.text
    except requests.RequestException as e:
        t1 = time.perf_counter()
        status, body = None, f"TRANSPORT ERROR {e}"
    ms = round((t1 - t0) * 1000, 1)
    exp = expect if isinstance(expect, tuple) else ((expect,) if expect is not None else None)
    ok = (status in exp) if exp else (status is not None and status < 400)
    rec = {
        "id": cid, "area": area, "role": role, "title": title,
        "actor": user.label if user else "anon", "method": method, "path": path,
        "status": status, "expect": list(exp) if exp else "<400", "ms": ms, "ok": ok,
        "finding": finding, "t_send": t0, "t_resp": t1, "at": now_iso(),
        "resp": json.dumps(body, ensure_ascii=False, default=str)[:700] if not raw else "<raw>",
    }
    RESULTS.append(rec)
    log(f"[{'PASS' if ok else 'FAIL'}] {cid:<6} {method:<6} {path:<58} -> {status} ({ms} ms) "
        f"expect={rec['expect']}  {title}")
    if json_body is not None:
        log(f"         req: {json.dumps(json_body, ensure_ascii=False)[:300]}")
    log(f"         res: {rec['resp'][:400]}")
    return rec, body


# ── Socket.IO ─────────────────────────────────────────────────
class Sock:
    def __init__(self, user):
        self.user = user
        self.events = []
        self.cv = threading.Condition()
        self.sio = socketio.Client(reconnection=False)
        self.connect_ms = None
        self.sio.on("*", self._on_any)

    def _on_any(self, event, data=None):
        t = time.perf_counter()
        size = len(json.dumps(data, default=str).encode()) if data is not None else 0
        ev = {"user": self.user.label, "event": event, "t": t, "at": now_iso(), "data": data, "bytes": size}
        with self.cv:
            self.events.append(ev)
            self.cv.notify_all()
        EVENTS.append({k: v for k, v in ev.items() if k != "data"} | {"list_id": (data or {}).get("list_id"),
                                                                       "group_id": (data or {}).get("group_id")})

    def connect(self, token):
        t0 = time.perf_counter()
        self.sio.connect(HOST, auth={"token": token}, transports=["websocket"], wait_timeout=20)
        self.connect_ms = round((time.perf_counter() - t0) * 1000, 1)
        return self.connect_ms

    def wait(self, event, since, pred=lambda d: True, timeout=8.0):
        end = time.perf_counter() + timeout
        with self.cv:
            while True:
                for ev in self.events:
                    if ev["event"] == event and ev["t"] >= since and pred(ev["data"] or {}):
                        return ev
                rem = end - time.perf_counter()
                if rem <= 0:
                    return None
                self.cv.wait(rem)

    def disconnect(self):
        try:
            self.sio.disconnect()
        except Exception:  # noqa: BLE001
            pass


SOCKET_LAT = []  # {event, from, to, ms_from_send, ms_after_resp, bytes}


def expect_event(cid, receiver, event, rec, pred=lambda d: True, should_arrive=True, timeout=8.0):
    ev = receiver.sock.wait(event, rec["t_send"], pred, timeout=timeout if should_arrive else 3.0)
    arrived = ev is not None
    ok = arrived == should_arrive
    lat = round((ev["t"] - rec["t_send"]) * 1000, 1) if ev else None
    after = round((ev["t"] - rec["t_resp"]) * 1000, 1) if ev else None
    entry = {"id": cid, "event": event, "to": receiver.label, "from": rec["actor"], "should_arrive": should_arrive,
             "arrived": arrived, "ok": ok, "ms_from_send": lat, "ms_after_resp": after,
             "bytes": ev["bytes"] if ev else None}
    SOCKET_LAT.append(entry)
    log(f"  [WS {'PASS' if ok else 'FAIL'}] {cid} {event} -> {receiver.label}: "
        f"{'arrived' if arrived else 'not received'} {'' if lat is None else f'+{lat} ms from send ({after} ms after HTTP response), {entry[chr(98)+chr(121)+chr(116)+chr(101)+chr(115)]} B'}"
        f"{'' if should_arrive else ' (must NOT arrive)'}")
    return ev


def tiny_png():
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    raw = b"\x00\xff\x00\x00"
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


def bench(user, label, path, n=10):
    times = []
    for _ in range(n):
        t0 = time.perf_counter()
        r = user.s.get(BASE + path, headers={"Authorization": f"Bearer {user.access}"}, timeout=60)
        times.append((time.perf_counter() - t0) * 1000)
        if r.status_code >= 400:
            log(f"  bench {label} got {r.status_code}")
    times.sort()
    PERF[label] = {"path": path, "n": n, "p50": round(median(times), 1),
                   "p95": round(times[min(n - 1, int(round(0.95 * n)) - 1)], 1),
                   "min": round(times[0], 1), "max": round(times[-1], 1)}
    log(f"  PERF {label:<28} p50={PERF[label]['p50']} ms p95={PERF[label]['p95']} ms max={PERF[label]['max']} ms")


def burst(user, path, n=10):
    out = [None] * n

    def one(i):
        t0 = time.perf_counter()
        r = requests.get(BASE + path, headers={"Authorization": f"Bearer {user.access}"}, timeout=90)
        out[i] = ((time.perf_counter() - t0) * 1000, r.status_code)

    t0 = time.perf_counter()
    ths = [threading.Thread(target=one, args=(i,)) for i in range(n)]
    [t.start() for t in ths]
    [t.join() for t in ths]
    wall = (time.perf_counter() - t0) * 1000
    lat = sorted(x[0] for x in out)
    PERF[f"burst{n} {path}"] = {"path": path, "n": n, "wall_ms": round(wall, 1), "p50": round(median(lat), 1),
                                "max": round(lat[-1], 1), "statuses": sorted({x[1] for x in out})}
    log(f"  BURST {n}x {path}: wall={wall:.0f} ms p50={median(lat):.0f} ms max={lat[-1]:.0f} ms "
        f"statuses={sorted({x[1] for x in out})}")


# ══════════════════════════════════════════════════════════════
def main():
    A, B = User("A", A_PHONE), User("B", B_PHONE)
    log(f"=== Zaytona E2E QA run {RUN_TAG} against {BASE} ===")

    # ── 0. warm-up / cold start ───────────────────────────────
    call("S0", "Platform", "anon", "Warm-up: public categories", None, "GET", "/categories/", expect=200)

    # ── 1. Auth ───────────────────────────────────────────────
    r, b = call("AU01", "Auth", "individual", "Login with local phone shape 05XXXXXXXX", A, "POST", "/auth/login",
                json_body={"identifier": "0555455544"}, expect=200)
    if isinstance(b, dict):
        log(f"  login normalized phone={b.get('phone')} otp_method={b.get('otp_method')}")
    call("AU02", "Auth", "individual", "Verify with wrong OTP is rejected", A, "POST", "/auth/otp/verify",
         json_body={"phone": A_PHONE, "token": "0000"}, expect=400)
    r, b = call("AU03", "Auth", "individual", "Verify whitelisted OTP 4444 -> tokens", A, "POST", "/auth/otp/verify",
                json_body={"phone": A_PHONE, "token": OTP}, expect=200)
    A.access, A.refresh, A.user_id = b["access_token"], b["refresh_token"], b["user"]["user_id"]
    A.first_access = A.access
    # Verify-first: /otp/verify never dispatches an OTP, so it is a free probe
    # of the whitelist. Only once it succeeds is B's /login (which would send
    # a real SMS for a non-whitelisted number) exercised.
    r, b = call("AU04", "Auth", "member", "Verify B with OTP 4444 (whitelist probe, sends nothing)", B, "POST",
                "/auth/otp/verify", json_body={"phone": B_PHONE, "token": OTP}, expect=200)
    if not isinstance(b, dict) or "access_token" not in b:
        log("ABORT: account B is not on the production OTP whitelist.")
        sys.exit(3)
    B.access, B.refresh, B.user_id = b["access_token"], b["refresh_token"], b["user"]["user_id"]
    r, b = call("AU05", "Auth", "member", "Login account B (international shape) -> dev-bypass", B, "POST",
                "/auth/login", json_body={"identifier": B_PHONE}, expect=200)
    if isinstance(b, dict):
        log(f"  B otp_method={b.get('otp_method')}")
    T_LOGIN = time.time()
    call("AU06", "Auth", "individual", "GET /auth/me with access token", A, "GET", "/auth/me", expect=200)
    call("AU07", "Auth", "anon", "GET /auth/me without token", A, "GET", "/auth/me", token="none", expect=401)
    call("AU08", "Auth", "individual", "Refresh token cannot be used as access token", A, "GET", "/auth/me",
         token="refresh", expect=401)
    r, b = call("AU09", "Auth", "individual", "Refresh -> new access token", A, "POST", "/auth/refresh",
                json_body={"refresh_token": A.refresh}, expect=200)
    if isinstance(b, dict) and b.get("access_token"):
        A.access = b["access_token"]
    call("AU10", "Auth", "individual", "Access token rejected by /auth/refresh", A, "POST", "/auth/refresh",
         json_body={"refresh_token": A.first_access}, expect=401)
    call("AU11", "Auth", "anon", "Register with an existing phone -> 409", None, "POST", "/auth/register",
         json_body={"first_name": "QA", "last_name": "Dup", "phone": A_PHONE}, expect=409)
    call("AU12", "Auth", "anon", "Login with unregistered phone -> 404 (no OTP sent)", None, "POST", "/auth/login",
         json_body={"identifier": UNKNOWN_PHONE}, expect=404)
    call("AU13", "Auth", "anon", "Login with malformed phone -> 400", None, "POST", "/auth/login",
         json_body={"identifier": "12345"}, expect=400)
    call("AU14", "Auth", "individual", "Resend OTP (whitelisted -> dev-bypass)", A, "POST", "/auth/otp/resend",
         json_body={"phone": A_PHONE}, expect=200)
    call("AU15", "Auth", "individual", "Resend OTP with invalid channel -> 400", A, "POST", "/auth/otp/resend",
         json_body={"phone": A_PHONE, "channel": "pigeon"}, expect=400)
    r, b = call("AU16", "Profile", "individual", "List preset avatars (Supabase Storage)", A, "GET", "/auth/avatars",
                expect=200)
    avatars = (b or {}).get("avatars", []) if isinstance(b, dict) else []
    log(f"  avatars: {len(avatars)} -> {[a['id'] for a in avatars][:12]}")
    me = call("AU17", "Profile", "individual", "Read profile before avatar test", A, "GET", "/auth/me", expect=200)[1]
    cur_avatar = (me or {}).get("avatar_url") or ""
    cur_id = cur_avatar.rstrip("?").rsplit("/", 1)[-1] if cur_avatar else (avatars[0]["id"] if avatars else "av-1.png")
    r, b = call("AU18", "Profile", "individual", "Select avatar (same as current) -> stored URL shape", A, "POST",
                "/auth/profile/avatar/select", json_body={"avatar_id": cur_id}, expect=200,
                finding="F-AVATAR-URL")
    sel_url = ((b or {}).get("user") or {}).get("avatar_url") if isinstance(b, dict) else None
    list_url = next((a["url"] for a in avatars if a["id"] == cur_id), None)
    log(f"  avatar URL from /avatars = {list_url!r}\n  avatar URL stored by /select = {sel_url!r}  "
        f"(equal={sel_url == list_url})")
    call("AU19", "Profile", "individual", "Select unknown avatar -> 404", A, "POST", "/auth/profile/avatar/select",
         json_body={"avatar_id": "nope.png"}, expect=404)
    call("AU20", "Profile", "individual", "Toggle reminders off", A, "PATCH", "/auth/me",
         json_body={"reminders_enabled": False}, expect=200)
    call("AU21", "Profile", "individual", "Toggle reminders back on", A, "PATCH", "/auth/me",
         json_body={"reminders_enabled": True}, expect=200)

    # ── 2. Socket.IO negative handshakes ─────────────────────
    for cid, title, tok in (("WS01", "Handshake without token is rejected", None),
                            ("WS02", "Handshake with refresh token is rejected", A.refresh),
                            ("WS03", "Handshake with garbage token is rejected", "abc.def.ghi")):
        s = socketio.Client(reconnection=False)
        t0 = time.perf_counter()
        try:
            s.connect(HOST, auth={"token": tok} if tok else None, transports=["websocket"], wait_timeout=15)
            res, ok = "CONNECTED (should have been rejected)", False
            s.disconnect()
        except socketio.exceptions.ConnectionError as e:
            res, ok = f"rejected: {e}", True
        ms = round((time.perf_counter() - t0) * 1000, 1)
        RESULTS.append({"id": cid, "area": "Realtime", "role": "anon", "title": title, "actor": "anon",
                        "method": "WS", "path": "/socket.io", "status": res, "expect": "rejected",
                        "ms": ms, "ok": ok, "finding": None, "at": now_iso(), "resp": res})
        log(f"[{'PASS' if ok else 'FAIL'}] {cid} WS handshake -> {res} ({ms} ms) {title}")

    # ── 3. Individual: personal group ─────────────────────────
    r, groups = call("IN01", "Groups", "individual", "List my groups (A)", A, "GET", "/groups", expect=200)
    personal = next((g for g in groups if g.get("type") == "individual"), None)
    log(f"  A personal group: {personal and personal['group_id']} role={personal and personal.get('role')} "
        f"members={personal and personal.get('member_count')}")
    pg = personal["group_id"]
    r, plists = call("IN02", "Lists", "individual", "Personal group lists", A, "GET", f"/groups/{pg}/lists", expect=200)
    existing = len(plists) if isinstance(plists, list) else 0
    created_personal = []
    for i in range(existing, 5):
        r, b = call(f"IN03.{i}", "Lists", "individual", f"Create personal list #{i + 1} (cap 5)", A, "POST",
                    f"/groups/{pg}/lists", json_body={"name": f"QA personal {i + 1}"}, expect=201)
        if isinstance(b, dict) and b.get("list_id"):
            created_personal.append(b["list_id"])
    call("IN04", "Lists", "individual", "6th list in personal group is blocked (US-13 cap)", A, "POST",
         f"/groups/{pg}/lists", json_body={"name": "QA over cap"}, expect=409)
    call("IN05", "Groups", "individual", "Personal group cannot be deleted", A, "DELETE", f"/groups/{pg}", expect=403)
    call("IN06", "Groups", "outsider", "Outsider cannot read someone's personal group", B, "GET", f"/groups/{pg}",
         expect=403)
    call("IN07", "Recipes", "outsider", "Outsider lists recipes of a group they are not in (expect 403)", B, "GET",
         f"/recipes/groups/{pg}/recipes", expect=403, finding="F-RECIPE-500")
    call("IN08", "Lists", "outsider", "Outsider cannot read a personal list", B, "GET",
         f"/lists/{created_personal[0] if created_personal else plists[0]['list_id']}", expect=403)
    for i, lid in enumerate(created_personal):
        call(f"IN09.{i}", "Lists", "individual", "Cleanup: delete QA personal list", A, "DELETE", f"/lists/{lid}",
             expect=204)

    # ── 4. Sockets up for A and B ─────────────────────────────
    A.sock, B.sock = Sock(A), Sock(B)
    A.sock.connect(A.access)
    B.sock.connect(B.access)
    log(f"  socket handshake: A={A.sock.connect_ms} ms, B={B.sock.connect_ms} ms")
    PERF["socket_handshake_A"] = {"ms": A.sock.connect_ms}
    PERF["socket_handshake_B"] = {"ms": B.sock.connect_ms}

    # ── 5. Group lifecycle (admin A, member B) ────────────────
    gname = f"QA E2E {RUN_TAG}"
    r, g = call("G01", "Groups", "admin", "Create household group (client sends type=individual)", A, "POST",
                "/groups", json_body={"name": gname, "icon": "home", "type": "individual"}, expect=201)
    gid, code = g["group_id"], g["invite_code"]
    log(f"  group {gid} type={g.get('type')} invite={code}")
    db_check("DB01", "Group row + admin membership written", "select g.type::text, m.role::text from groups g join "
             "group_members m using(group_id) where g.group_id=%s", (gid,),
             lambda rows: rows == [("household", "admin")], "1 row: household/admin")
    call("G02", "Groups", "admin", "Blank group name rejected", A, "POST", "/groups", json_body={"name": "   "},
         expect=400)
    r, b = call("G03", "Groups", "member", "Join with lowercase invite code", B, "POST", "/groups/join",
                json_body={"invite_code": code.lower()}, expect=200)
    expect_event("G03a", A, "group.member_joined", r, lambda d: d.get("group_id") == gid)
    expect_event("G03b", B, "group.membership_changed", r, lambda d: d.get("reason") == "joined")
    call("G04", "Groups", "member", "Join again -> 409", B, "POST", "/groups/join", json_body={"invite_code": code},
         expect=409)
    call("G05", "Groups", "member", "Invalid invite code -> 404", B, "POST", "/groups/join",
         json_body={"invite_code": "ZZZZZZ"}, expect=404)
    r, b = call("G06", "Groups", "member", "Group detail as member", B, "GET", f"/groups/{gid}", expect=200)
    log(f"  B role={b.get('role')} members={len(b.get('members', []))}")
    call("G07", "Groups", "member", "Member cannot rename group", B, "PATCH", f"/groups/{gid}",
         json_body={"name": "hacked"}, expect=403)
    r, b = call("G08", "Groups", "admin", "Admin renames group + icon (Arabic name)", A, "PATCH", f"/groups/{gid}",
                json_body={"name": "عائلة الاختبار", "icon": "cart"}, expect=200, finding="F-AR-NORMALIZE")
    log(f"  stored group name: {b.get('name')!r} (sent 'عائلة الاختبار')")
    expect_event("G08a", B, "group.updated", r, lambda d: d.get("group_id") == gid)
    call("G09", "Groups", "admin", "Invalid icon rejected", A, "PATCH", f"/groups/{gid}", json_body={"icon": "rocket"},
         expect=400)
    r, b = call("G10", "Groups", "member", "My groups (B) shows member_count + role", B, "GET", "/groups", expect=200)
    mine = next((x for x in b if x["group_id"] == gid), {})
    log(f"  B sees member_count={mine.get('member_count')} role={mine.get('role')}")
    call("G11", "Groups", "member", "Malformed group id -> 404", B, "GET", "/groups/not-a-uuid", expect=404)

    # ── 6. Lists ─────────────────────────────────────────────
    r, b = call("L01", "Lists", "admin", "Admin creates list (Arabic name)", A, "POST", f"/groups/{gid}/lists",
                json_body={"name": "قائمة الشهر"}, expect=201, finding="F-AR-NORMALIZE")
    L1 = b["list_id"]
    log(f"  stored list name: {b.get('name')!r} (sent 'قائمة الشهر')")
    expect_event("L01a", B, "list.created", r, lambda d: d.get("list", {}).get("list_id") == L1)
    r, b = call("L02", "Lists", "member", "Member creates list", B, "POST", f"/groups/{gid}/lists",
                json_body={"name": "QA Lock Test"}, expect=201)
    L2 = b["list_id"]
    expect_event("L02a", A, "list.created", r, lambda d: d.get("list", {}).get("list_id") == L2)
    call("L03", "Lists", "member", "Member cannot rename list (admin-only)", B, "PATCH", f"/lists/{L1}",
         json_body={"name": "x"}, expect=403)
    call("L04", "Lists", "admin", "Invalid list colour rejected", A, "PATCH", f"/lists/{L1}",
         json_body={"color": "pink"}, expect=400)
    r, b = call("L05", "Lists", "admin", "Admin sets list colour", A, "PATCH", f"/lists/{L1}",
                json_body={"color": "mint"}, expect=200)
    expect_event("L05a", B, "list.updated", r, lambda d: d.get("list", {}).get("list_id") == L1)
    call("L06", "Lists", "member", "Member reads list", B, "GET", f"/lists/{L1}", expect=200)
    call("L07", "Lists", "member", "Bad status filter -> 400", B, "GET", f"/groups/{gid}/lists?status=bogus",
         expect=400)

    # ── 7. Items ─────────────────────────────────────────────
    cats = requests.get(BASE + "/categories/", timeout=30).json()
    dairy = next(c["category_id"] for c in cats if c["name"].startswith("Dairy"))
    r, b = call("I01", "Items", "member", "Member adds Milk 2 L (Almarai)", B, "POST", f"/lists/{L1}/items",
                json_body={"name": "Milk", "quantity": 2, "unit": "L", "brand": "Almarai", "category_id": dairy},
                expect=201)
    milk = b["list_item_id"]
    expect_event("I01a", A, "item.added", r, lambda d: d.get("item", {}).get("list_item_id") == milk)
    r, b = call("I02", "Items", "admin", "Same name+unit from another member merges (brand/notes/urgent sent)", A,
                "POST", f"/lists/{L1}/items",
                json_body={"name": "milk", "quantity": 1, "unit": "L", "brand": "Nadec", "notes": "low fat",
                           "is_urgent": True}, expect=209, finding="F-MERGE-LOSS")
    log(f"  merged row: qty={b.get('quantity')} brand={b.get('brand')!r} notes={b.get('notes')!r} "
        f"urgent={b.get('is_urgent')} same_id={b.get('list_item_id') == milk}")
    expect_event("I02a", B, "item.updated", r, lambda d: d.get("item", {}).get("list_item_id") == milk)
    r, b = call("I03", "Items", "admin", "Same name, different unit -> new row + warning", A, "POST",
                f"/lists/{L1}/items", json_body={"name": "Milk", "quantity": 1, "unit": "pcs"}, expect=209)
    milk_pcs = b.get("list_item_id")
    call("I04", "Items", "admin", "Invalid unit rejected", A, "POST", f"/lists/{L1}/items",
         json_body={"name": "Bread", "unit": "kgs"}, expect=400)
    call("I05", "Items", "admin", "Zero quantity rejected", A, "POST", f"/lists/{L1}/items",
         json_body={"name": "Bread", "quantity": 0}, expect=400)
    call("I06", "Items", "admin", "Malformed catalog item_id (expect 400/404)", A, "POST", f"/lists/{L1}/items",
         json_body={"name": "Bread", "item_id": "not-a-uuid"}, expect=(400, 404), finding="F-UUID-500")
    call("I07", "Items", "admin", "Malformed category_id rejected", A, "POST", f"/lists/{L1}/items",
         json_body={"name": "Bread", "category_id": "nope"}, expect=400)
    r, b = call("I08", "Items", "admin", "Arabic item name قهوة", A, "POST", f"/lists/{L1}/items",
                json_body={"name": "قهوة", "quantity": 1, "unit": "pack"}, expect=201, finding="F-AR-NORMALIZE")
    log(f"  stored item name: {b.get('name')!r} (sent 'قهوة')")
    coffee = b.get("list_item_id")
    call("I09", "Items", "admin", "Everyday note with a semicolon (expect accepted)", A, "POST", f"/lists/{L1}/items",
         json_body={"name": "Eggs", "notes": "2 trays; large"}, expect=201, finding="F-SQLI-FILTER")
    call("I10", "Items", "admin", "Everyday note 'select ... from ...' (expect accepted)", A, "POST",
         f"/lists/{L1}/items", json_body={"name": "Bread", "notes": "select the fresh ones from the bakery"},
         expect=201, finding="F-SQLI-FILTER")
    r, b = call("I11", "Items", "admin", "Urgent item Tomatoes 2 kg", A, "POST", f"/lists/{L1}/items",
                json_body={"name": "Tomatoes", "quantity": 2, "unit": "kg", "is_urgent": True}, expect=201)
    tom = b["list_item_id"]
    r, items = call("I12", "Items", "member", "List items (urgent first)", B, "GET", f"/lists/{L1}/items", expect=200)
    log(f"  order: {[(i['name'], i['is_urgent']) for i in items]}")
    r, b = call("I13", "Items", "admin", "Edit quantity 2 -> 3", A, "PATCH", f"/lists/{L1}/items/{tom}",
                json_body={"quantity": 3}, expect=200)
    expect_event("I13a", B, "item.updated", r, lambda d: d.get("item", {}).get("list_item_id") == tom)
    call("I14", "Items", "admin", "Edit quantity 0 rejected", A, "PATCH", f"/lists/{L1}/items/{tom}",
         json_body={"quantity": 0}, expect=400)
    r, b = call("I15", "Items", "member", "Member checks item (no trip)", B, "PATCH",
                f"/lists/{L1}/items/{tom}/purchase", json_body={"is_bought": True}, expect=200)
    expect_event("I15a", A, "item.purchased", r, lambda d: d.get("item", {}).get("list_item_id") == tom)
    call("I16", "Items", "member", "Check again is idempotent", B, "PATCH", f"/lists/{L1}/items/{tom}/purchase",
         json_body={"is_bought": True}, expect=200)
    r, b = call("I17", "Items", "member", "Uncheck item", B, "PATCH", f"/lists/{L1}/items/{tom}/purchase",
                json_body={"is_bought": False}, expect=200)
    expect_event("I17a", A, "item.unpurchased", r, lambda d: d.get("item", {}).get("list_item_id") == tom)
    db_check("DB02", "Idempotent purchase wrote exactly 1 'consumed' + 1 'restocked'",
             "select action::text, count(*) from list_actions where list_item_id=%s and action in "
             "('consumed','restocked') group by 1 order by 1", (tom,),
             lambda rows: rows == [("consumed", 1), ("restocked", 1)], "consumed=1, restocked=1")
    call("I18", "Items", "admin", "Personal quick-add catalog", A, "GET", "/users/me/items", expect=200)
    r, b = call("I19", "Catalog", "admin", "Catalog search Arabic with taa marbuta (قهوة)", A, "GET",
                "/catalog/search?q=قهوة", expect=200)
    log(f"  search 'قهوة' -> {len(b) if isinstance(b, list) else b}")
    call("I20", "Catalog", "admin", "Catalog search latin", A, "GET", "/catalog/search?q=Milk", expect=200)
    r, b = call("I21", "Items", "admin", "Upload item photo (PNG)", A, "POST", f"/lists/{L1}/items/{tom}/image",
                files={"image": ("qa.png", tiny_png(), "image/png")}, expect=201)
    expect_event("I21a", B, "item.updated", r, lambda d: d.get("item", {}).get("list_item_id") == tom)
    call("I22", "Items", "admin", "Upload non-image rejected", A, "POST", f"/lists/{L1}/items/{tom}/image",
         files={"image": ("qa.txt", b"hello", "text/plain")}, expect=400)
    r, b = call("I23", "Items", "member", "Delete Milk(pcs) row", B, "DELETE", f"/lists/{L1}/items/{milk_pcs}",
                expect=200)
    expect_event("I23a", A, "item.deleted", r, lambda d: d.get("list_item_id") == milk_pcs)

    # ── 8. Trip lifecycle on L1 (A assigns B) ─────────────────
    r, trip = call("T01", "Trips", "admin", "Assign member B as buyer", A, "POST", f"/lists/{L1}/trip",
                   json_body={"buyer_id": B.user_id}, expect=(200, 201))
    tid = trip["trip_id"]
    expect_event("T01a", B, "trip.assigned", r, lambda d: d.get("list_id") == L1)
    expect_event("T01b", A, "trip.assigned", r, lambda d: d.get("list_id") == L1)
    call("T02", "Trips", "admin", "Second active trip -> 409", A, "POST", f"/lists/{L1}/trip",
         json_body={"buyer_id": A.user_id}, expect=409)
    call("T03", "Trips", "admin", "Active trip lookup", A, "GET", f"/lists/{L1}/trips/active", expect=200)
    call("T04", "Trips", "admin", "Non-buyer cannot check items during trip", A, "PATCH",
         f"/lists/{L1}/items/{tom}/purchase", json_body={"is_bought": True}, expect=403)
    for cid, iid in (("T05", milk), ("T06", tom)):
        r, b = call(cid, "Trips", "member", "Buyer checks item", B, "PATCH", f"/lists/{L1}/items/{iid}/purchase",
                    json_body={"is_bought": True}, expect=200)
    r, b = call("T07", "Trips", "admin", "Admin adds item mid-trip (buyer push attempted)", A, "POST",
                f"/lists/{L1}/items", json_body={"name": "Sugar", "quantity": 1, "unit": "kg"}, expect=201)
    sugar = b["list_item_id"]
    expect_event("T07a", B, "item.added", r, lambda d: d.get("item", {}).get("list_item_id") == sugar)
    call("T08", "Trips", "admin", "Non-buyer cannot announce heading-out", A, "POST", f"/trips/{tid}/heading-out",
         expect=403)
    r, b = call("T09", "Trips", "member", "Buyer announces heading-out (push + socket)", B, "POST",
                f"/trips/{tid}/heading-out", expect=200, finding="F-FCM-ENV")
    log(f"  heading-out notified_devices={b.get('notified_devices') if isinstance(b, dict) else b}")
    expect_event("T09a", A, "trip.heading_out", r, lambda d: d.get("trip_id") == tid)
    call("T10", "Trips", "member", "Ask with empty recipients -> 400", B, "POST", f"/trips/{tid}/ask",
         json_body={"recipient_ids": []}, expect=400)
    call("T11", "Trips", "member", "Ask with non-member id -> 400", B, "POST", f"/trips/{tid}/ask",
         json_body={"recipient_ids": [str(uuid.uuid4())]}, expect=400)
    r, b = call("T12", "Trips", "member", "Buyer privately asks A", B, "POST", f"/trips/{tid}/ask",
                json_body={"recipient_ids": [A.user_id]}, expect=200)
    expect_event("T12a", A, "trip.asked", r, lambda d: d.get("trip_id") == tid)
    expect_event("T12b", B, "trip.asked", r, lambda d: d.get("trip_id") == tid, should_arrive=False)
    call("T13", "Trips", "admin", "Non-buyer cannot complete trip", A, "PATCH", f"/trips/{tid}/complete", expect=403)
    r, b = call("T14", "Trips", "member", "Buyer completes trip", B, "PATCH", f"/trips/{tid}/complete", expect=200)
    expect_event("T14a", A, "trip.completed", r, lambda d: d.get("list_id") == L1)
    expect_event("T14b", A, "list.completed", r, lambda d: d.get("list", {}).get("list_id") == L1)
    db_check("DB03", "Trip closed and only bought items claimed",
             "select (select status::text from trips where trip_id=%s), (select count(*) from list_items where "
             "trip_id=%s), (select count(*) from list_items where list_id=%s and trip_id is null)", (tid, tid, L1),
             lambda rows: rows[0][0] == "completed" and rows[0][1] == 2, "status=completed, 2 claimed items")
    r, items = call("T15", "Trips", "member", "Active list hides claimed (bought) items", B, "GET",
                    f"/lists/{L1}/items", expect=200)
    log(f"  active items now: {[i['name'] for i in items]}")
    r, b = call("T16", "Lists", "admin", "List card counts after trip (expect claimed excluded)", A, "GET",
                f"/groups/{gid}/lists", expect=200, finding="F-COUNTS")
    card = next((x for x in b if x["list_id"] == L1), {})
    log(f"  L1 card: item_count={card.get('item_count')} bought_count={card.get('bought_count')} "
        f"(active rows visible={len(items)})")
    if card and card.get("item_count") != len(items):
        RESULTS[-1]["ok"] = False
        RESULTS[-1]["note"] = f"card item_count={card.get('item_count')} but list shows {len(items)}"
    r, b = call("T17", "History", "member", "Trip history for list", B, "GET", f"/lists/{L1}/trips", expect=200)
    log(f"  trips: {[(t['buyer_name'], t['item_count']) for t in b]}")
    r, hist = call("T18", "History", "member", "Action log for list", B, "GET", f"/lists/{L1}/history", expect=200)
    log(f"  history entries: {len(hist)} actions={sorted({h.get('action') for h in hist})}")
    r, b = call("T19", "Trips", "member", "Cancel an already-completed trip (expect 409)", B, "PATCH",
                f"/trips/{tid}/cancel", expect=(400, 409), finding="F-TRIP-STATE")
    r, b = call("T20", "History", "member", "Trip history after cancelling completed trip", B, "GET",
                f"/lists/{L1}/trips", expect=200)
    log(f"  trips after cancel-of-completed: {len(b)} (was 1)")
    if isinstance(b, list) and len(b) == 0:
        RESULTS[-1]["ok"] = False
        RESULTS[-1]["note"] = "completed trip vanished from history after /cancel"

    # ── 9. Trip lock bypass via PATCH /lists/{id}/complete ───
    r, b = call("T21", "Trips", "member", "Member adds Rice to lock-test list", B, "POST", f"/lists/{L2}/items",
                json_body={"name": "Rice", "quantity": 5, "unit": "kg"}, expect=201)
    r, trip2 = call("T22", "Trips", "admin", "Assign B as buyer on lock-test list", A, "POST", f"/lists/{L2}/trip",
                    json_body={"buyer_id": B.user_id}, expect=(200, 201))
    tid2 = trip2["trip_id"]
    call("T23", "Trips", "admin", "Non-buyer closes list via /lists/{id}/complete (expect 403)", A, "PATCH",
         f"/lists/{L2}/complete", expect=403, finding="F-TRIP-BYPASS")
    db_check("DB04", "Buyer's trip must still be active after non-buyer /complete",
             "select status::text from trips where trip_id=%s", (tid2,),
             lambda rows: rows and rows[0][0] == "active", "status=active")

    # ── 10. Bulk delete vs trip history, history cascade ─────
    r, trip3 = call("T24", "Trips", "admin", "Admin self-assigns as buyer on L1", A, "POST", f"/lists/{L1}/trip",
                    json_body={"buyer_id": A.user_id}, expect=(200, 201))
    tid3 = trip3["trip_id"]
    call("T25", "Trips", "admin", "Buyer checks Sugar", A, "PATCH", f"/lists/{L1}/items/{sugar}/purchase",
         json_body={"is_bought": True}, expect=200)
    call("T26", "Trips", "admin", "Buyer completes trip 3", A, "PATCH", f"/trips/{tid3}/complete", expect=200)
    r, b = call("T27", "History", "admin", "Trip 3 in history", A, "GET", f"/lists/{L1}/trips", expect=200)
    before = next((t["item_count"] for t in b if t["trip_id"] == tid3), None)
    r, b = call("T28", "Items", "admin", "Bulk delete (clear list)", A, "DELETE", f"/lists/{L1}/items", expect=200)
    expect_event("T28a", B, "item.bulk_deleted", r, lambda d: d.get("list_id") == L1)
    log(f"  bulk delete says: {b}")
    r, b = call("T29", "History", "admin", "Trip history must survive clearing the list", A, "GET",
                f"/lists/{L1}/trips", expect=200, finding="F-BULK-HISTORY")
    after = next((t["item_count"] for t in b if t["trip_id"] == tid3), None)
    log(f"  trip3 item_count before clear={before} after clear={after}")
    if before != after:
        RESULTS[-1]["ok"] = False
        RESULTS[-1]["note"] = f"trip item_count {before} -> {after} after bulk delete"
    r, b = call("H01", "History", "member", "Add Yogurt (history: created)", B, "POST", f"/lists/{L2}/items",
                json_body={"name": "Yogurt", "quantity": 4, "unit": "pcs"}, expect=(201, 209))
    yog = b["list_item_id"]
    call("H02", "History", "member", "Edit Yogurt qty (history: updated)", B, "PATCH", f"/lists/{L2}/items/{yog}",
         json_body={"quantity": 6}, expect=200)
    call("H03", "History", "member", "Delete Yogurt (history: deleted)", B, "DELETE", f"/lists/{L2}/items/{yog}",
         expect=200)
    db_check("DB05", "Yogurt's created/updated history survives item deletion",
             "select count(*) from list_actions where list_id=%s and action in ('created','updated') and "
             "metadata->>'name'='Yogurt'", (L2,), lambda rows: rows[0][0] >= 2,
             ">=2 rows (model says ON DELETE SET NULL)")

    # ── 11. Cancel flow ──────────────────────────────────────
    r, trip4 = call("C01", "Trips", "admin", "Assign B as buyer again on L2", A, "POST", f"/lists/{L2}/trip",
                    json_body={"buyer_id": B.user_id}, expect=(200, 201, 409))
    if isinstance(trip4, dict) and trip4.get("trip_id"):
        tid4 = trip4["trip_id"]
        r, b = call("C02", "Trips", "member", "Buyer cancels trip", B, "PATCH", f"/trips/{tid4}/cancel", expect=200)
        expect_event("C02a", A, "trip.cancelled", r, lambda d: d.get("list_id") == L2)
        call("C03", "Trips", "member", "Cancel twice (expect 409)", B, "PATCH", f"/trips/{tid4}/cancel",
             expect=(400, 409), finding="F-TRIP-STATE")
        call("C04", "Trips", "member", "Heading-out on a cancelled trip (expect 409)", B, "POST",
             f"/trips/{tid4}/heading-out", expect=(400, 409), finding="F-TRIP-STATE")

    # ── 12. Devices + FCM probe ──────────────────────────────
    probe = f"qa-probe-{int(time.time())}"
    call("D01", "Push", "member", "Register a probe FCM token for B", B, "POST", "/devices",
         json_body={"fcm_token": probe, "platform": "android"}, expect=(200, 201))
    call("D02", "Push", "admin", "A cannot delete B's token (IDOR guard)", A, "DELETE", f"/devices/{probe}",
         expect=404)
    r, b = call("N01", "Push", "admin", "Remind member B (push to B's devices)", A, "POST",
                f"/lists/{L1}/notifications/remind-member", json_body={"user_id": B.user_id}, expect=200,
                finding="F-FCM-ENV")
    db_check("DB06", "FCM probe: invalid token pruned only if Firebase is configured",
             "select count(*) from user_devices where fcm_token=%s", (probe,), lambda rows: rows[0][0] == 0,
             "0 rows (FCM rejected the fake token and it was pruned)")
    call("N02", "Push", "admin", "Remind me", A, "POST", f"/lists/{L1}/notifications/remind-me", expect=200)
    call("N03", "Push", "admin", "Remind non-member -> 400", A, "POST", f"/lists/{L1}/notifications/remind-member",
         json_body={"user_id": str(uuid.uuid4())}, expect=400)
    call("D03", "Push", "member", "Cleanup: B deletes probe token", B, "DELETE", f"/devices/{probe}",
         expect=(200, 404))

    # ── 13. Recipes (backend only; no app UI) ────────────────
    call("R00", "Recipes", "admin", "Seed Chicken on L2 (for duplicate-import check)", A, "POST",
         f"/lists/{L2}/items", json_body={"name": "Chicken", "quantity": 1, "unit": "kg"}, expect=(201, 209))
    r, rec = call("R01", "Recipes", "member", "Member creates recipe with ingredients", B, "POST",
                  f"/recipes/groups/{gid}/recipes", json_body={
                      "name": "كبسة", "instructions": "Cook",
                      "ingredients": [{"name": "Chicken", "quantity": 1, "unit": "kg"},
                                      {"name": "أرز", "quantity": 2, "unit": "kg"}]}, expect=201)
    rid = rec.get("recipe_id") if isinstance(rec, dict) else None
    expect_event("R01a", A, "recipe.created", r, lambda d: d.get("group_id") == gid)
    call("R02", "Recipes", "admin", "List group recipes", A, "GET", f"/recipes/groups/{gid}/recipes", expect=200)
    call("R03", "Recipes", "admin", "Recipe detail", A, "GET", f"/recipes/{rid}", expect=200)
    call("R04", "Recipes", "admin", "Malformed recipe id (expect 404)", A, "GET", "/recipes/not-a-uuid", expect=404,
         finding="F-UUID-500")
    call("R05", "Recipes", "admin", "Admin (not owner) renames recipe", A, "PATCH", f"/recipes/{rid}",
         json_body={"name": "Kabsa"}, expect=200)
    r, b = call("R06", "Recipes", "admin", "Import recipe into list", A, "POST",
                f"/recipes/lists/{L2}/items/from-recipe/{rid}", expect=201)
    expect_event("R06a", B, "list.items_imported", r, lambda d: d.get("list_id") == L2)
    r, items = call("R07", "Recipes", "admin", "Imported duplicates are merged like manual adds", A, "GET",
                    f"/lists/{L2}/items", expect=200, finding="F-IMPORT-DUP")
    chick = [i for i in items if i["name"].lower() == "chicken"]
    log(f"  Chicken rows after import: {len(chick)}")
    if len(chick) > 1:
        RESULTS[-1]["ok"] = False
        RESULTS[-1]["note"] = f"{len(chick)} separate Chicken rows (manual add would have merged)"
    call("R08", "Recipes", "admin", "Admin removes recipe via US-12 route", A, "DELETE",
         f"/groups/{gid}/recipes/{rid}", expect=204, finding="F-RECIPE-FK")
    call("R09", "Recipes", "member", "Owner deletes recipe (fallback route)", B, "DELETE", f"/recipes/{rid}",
         expect=(200, 404))

    # ── 14. Performance sampling (warm) ──────────────────────
    log("--- performance sampling ---")
    for label, path in (("GET /auth/me", "/auth/me"), ("GET /groups", "/groups"),
                        ("GET /groups/{id}", f"/groups/{gid}"), ("GET /groups/{id}/lists", f"/groups/{gid}/lists"),
                        ("GET /lists/{id}/items", f"/lists/{L2}/items"), ("GET /lists/{id}/history",
                                                                          f"/lists/{L1}/history"),
                        ("GET /lists/{id}/trips", f"/lists/{L1}/trips"), ("GET /users/me/items", "/users/me/items"),
                        ("GET /categories", "/categories/"), ("GET /auth/avatars", "/auth/avatars")):
        bench(A, label, path)
    burst(A, "/groups", 10)
    burst(A, f"/lists/{L2}/items", 10)

    # ── 15. Admin operations ─────────────────────────────────
    r, b = call("A01", "Groups", "admin", "Transfer admin to B", A, "POST", f"/groups/{gid}/transfer-admin",
                json_body={"new_admin_user_id": B.user_id}, expect=200)
    expect_event("A01a", B, "group.admin_transferred", r, lambda d: d.get("group_id") == gid)
    call("A02", "Groups", "member", "Former admin can no longer rename", A, "PATCH", f"/groups/{gid}",
         json_body={"name": "x"}, expect=403)
    call("A03", "Groups", "admin", "New admin transfers back", B, "POST", f"/groups/{gid}/transfer-admin",
         json_body={"new_admin_user_id": A.user_id}, expect=200)
    call("A04", "Groups", "admin", "Admin cannot remove self", A, "DELETE", f"/groups/{gid}/members/{A.user_id}",
         expect=400)
    r, b = call("A05", "Groups", "admin", "Admin removes member B", A, "DELETE",
                f"/groups/{gid}/members/{B.user_id}", expect=204)
    expect_event("A05a", A, "group.member_removed", r, lambda d: d.get("target_user_id") == B.user_id)
    expect_event("A05b", B, "group.membership_changed", r, lambda d: d.get("reason") == "removed")
    call("A06", "Groups", "outsider", "Removed member loses access", B, "GET", f"/groups/{gid}", expect=403)
    r, b = call("A07", "Realtime", "admin", "Item added after removal", A, "POST", f"/lists/{L2}/items",
                json_body={"name": "Salt", "quantity": 1, "unit": "pcs"}, expect=201)
    expect_event("A07a", B, "item.added", r, lambda d: d.get("list_id") == L2, should_arrive=False)
    call("A08", "Groups", "member", "B re-joins", B, "POST", "/groups/join", json_body={"invite_code": code},
         expect=200)
    call("A09", "Groups", "admin", "Admin cannot leave while others remain", A, "POST", f"/groups/{gid}/leave",
         expect=400)
    r, b = call("A10", "Groups", "member", "Member leaves", B, "POST", f"/groups/{gid}/leave", expect=200)
    expect_event("A10a", A, "group.member_left", r, lambda d: d.get("group_id") == gid)
    call("A11", "Groups", "member", "B re-joins for delete broadcast", B, "POST", "/groups/join",
         json_body={"invite_code": code}, expect=200)

    # ── 16. Deletion + DB integrity ──────────────────────────
    call("X01", "Lists", "admin", "Delete list that has completed trips", A, "DELETE", f"/lists/{L2}", expect=204)
    r, b = call("X02", "Groups", "admin", "Admin deletes group", A, "DELETE", f"/groups/{gid}", expect=204)
    expect_event("X02a", B, "group.deleted", r, lambda d: d.get("group_id") == gid)
    db_check("DB07", "No orphan rows left for deleted group",
             "select (select count(*) from groups where group_id=%s)+(select count(*) from group_members where "
             "group_id=%s)+(select count(*) from shopping_lists where group_id=%s)+(select count(*) from list_items "
             "where list_id in (%s,%s))+(select count(*) from trips where list_id in (%s,%s))+(select count(*) from "
             "list_actions where list_id in (%s,%s))+(select count(*) from recipes where group_id=%s)",
             (gid, gid, gid, L1, L2, L1, L2, L1, L2, gid), lambda rows: rows[0][0] == 0, "0 rows")
    call("X03", "Groups", "member", "Deleted group is gone", B, "GET", f"/groups/{gid}", expect=404)

    # ── 17. Token expiry vs. socket (needs >15 min since login) ──
    age = time.time() - T_LOGIN
    log(f"  first access token age: {age / 60:.1f} min")
    A.sock.disconnect()
    B.sock.disconnect()
    json.dump({"first_access": A.first_access, "issued_at": T_LOGIN}, open(OUT / "token_probe.json", "w"))

    summary = {"run": RUN_TAG, "base": BASE, "results": RESULTS, "socket": SOCKET_LAT, "events": EVENTS,
               "db": DBCHECKS, "perf": PERF, "ids": {"A": A.user_id, "B": B.user_id, "group": gid, "L1": L1,
                                                     "L2": L2}}
    for r in summary["results"]:
        r.pop("t_send", None)
        r.pop("t_resp", None)
    json.dump(summary, open(OUT / "api_results.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1,
              default=str)
    n = len(RESULTS)
    p = sum(1 for r in RESULTS if r["ok"])
    w = sum(1 for s in SOCKET_LAT if s["ok"])
    d = sum(1 for c in DBCHECKS if c["ok"])
    log(f"=== DONE: API {p}/{n} pass, WS {w}/{len(SOCKET_LAT)} pass, DB {d}/{len(DBCHECKS)} pass ===")


if __name__ == "__main__":
    try:
        main()
    finally:
        LOG.close()
