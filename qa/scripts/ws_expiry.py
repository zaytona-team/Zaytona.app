"""Expired-access-token probe: what a client holding a >15-min-old token
(the one SocketService.connect() reads from storage) gets from REST and
from the Socket.IO handshake."""
import base64
import json
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests
import socketio

HOST = "https://zaytona-app.onrender.com"
OUT = Path(__file__).parent / "results"
sys.stdout.reconfigure(encoding="utf-8")

log_text = (OUT / "api_log.txt").read_text(encoding="utf-8")
token = re.search(r'"access_token": "(eyJ[^"]+)"', log_text).group(1)
payload = json.loads(base64.urlsafe_b64decode(token.split(".")[1] + "=="))
exp = payload["exp"]
print(f"token type={payload['type']} iat={datetime.fromtimestamp(payload['iat'], timezone.utc)} "
      f"exp={datetime.fromtimestamp(exp, timezone.utc)}")
wait = exp - time.time() + 5
if wait > 0:
    print(f"waiting {wait:.0f}s for expiry...")
    time.sleep(wait)

result = {"token_iat": payload["iat"], "token_exp": exp, "tested_at": time.time()}
r = requests.get(HOST + "/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"}, timeout=60)
result["rest_status"], result["rest_body"] = r.status_code, r.text[:200]
print(f"REST /auth/me with expired token -> {r.status_code} {r.text[:120]}")

s = socketio.Client(reconnection=False)
t0 = time.perf_counter()
try:
    s.connect(HOST, auth={"token": token}, transports=["websocket"], wait_timeout=15)
    result["socket"] = "CONNECTED"
    s.disconnect()
except socketio.exceptions.ConnectionError as e:
    result["socket"] = f"rejected: {e}"
result["socket_ms"] = round((time.perf_counter() - t0) * 1000, 1)
print(f"Socket.IO handshake with expired token -> {result['socket']} ({result['socket_ms']} ms)")
json.dump(result, open(OUT / "ws_expiry.json", "w"), indent=1)
