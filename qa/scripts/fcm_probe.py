"""FCM configuration probe using account A only.

Registers a deliberately invalid FCM token for A, triggers a push to A
(remind-me on A's own QA list), then checks whether the backend pruned the
token. FirebaseProvider prunes tokens FCM rejects (INVALID_ARGUMENT /
UNREGISTERED) — which can only happen if credentials loaded and a send was
attempted. If FIREBASE_CREDENTIALS_JSON is missing, _ensure_initialized()
raises before any send and nothing is pruned.
"""
import json
import sys
import time
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).parent))
from dbq import query  # noqa: E402

BASE = "https://zaytona-app.onrender.com/api/v1"
A_PHONE = "+966555455544"
QA_LIST = sys.argv[1]
sys.stdout.reconfigure(encoding="utf-8")

s = requests.Session()
r = s.post(BASE + "/auth/login", json={"identifier": A_PHONE}, timeout=60).json()
assert r.get("otp_method") == "dev-bypass", r
tok = s.post(BASE + "/auth/otp/verify", json={"phone": A_PHONE, "token": "4444"}, timeout=60).json()
h = {"Authorization": f"Bearer {tok['access_token']}"}
uid = tok["user"]["user_id"]

probe = f"qa-fcm-probe-{int(time.time())}"
r1 = s.post(BASE + "/devices", json={"fcm_token": probe, "platform": "android"}, headers=h, timeout=60)
before = query("select count(*) from user_devices where user_id=%s", (uid,))[1][0][0]
t0 = time.perf_counter()
r2 = s.post(BASE + f"/lists/{QA_LIST}/notifications/remind-me", headers=h, timeout=60)
ms = round((time.perf_counter() - t0) * 1000)
time.sleep(2)
probe_left = query("select count(*) from user_devices where fcm_token=%s", (probe,))[1][0][0]
smoke_left = query("select count(*) from user_devices where user_id=%s and fcm_token like 'smoke-test%%'", (uid,))[1][0][0]
after = query("select count(*) from user_devices where user_id=%s", (uid,))[1][0][0]
result = {
    "register_status": r1.status_code, "remind_me_status": r2.status_code, "remind_me_ms": ms,
    "remind_me_body": r2.text[:200], "devices_before": before, "devices_after": after,
    "probe_token_still_present": probe_left == 1, "old_smoke_token_still_present": smoke_left == 1,
    "verdict": ("FCM NOT CONFIGURED (no send attempted, invalid tokens never pruned)"
                if probe_left == 1 else "FCM configured (invalid token pruned)"),
}
print(json.dumps(result, indent=1))
cleanup = s.delete(BASE + f"/devices/{probe}", headers=h, timeout=60)
print("cleanup delete probe ->", cleanup.status_code)
json.dump(result, open(Path(__file__).parent / "results" / "fcm_probe.json", "w"), indent=1)
