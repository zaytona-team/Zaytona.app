"""Act as account B over the API (B is whitelisted: verify-first, no SMS)."""
import json, sys, requests
B = "https://zaytona-app.onrender.com/api/v1"
sys.stdout.reconfigure(encoding="utf-8")
s = requests.Session()
v = s.post(B + "/auth/otp/verify", json={"phone": "+966555455545", "token": "4444"}, timeout=60)
assert v.status_code == 200, v.text
H = {"Authorization": "Bearer " + v.json()["access_token"]}
method, path = sys.argv[1], sys.argv[2]
body = json.loads(sys.argv[3]) if len(sys.argv) > 3 else None
r = s.request(method, B + path, json=body, headers=H, timeout=60)
print(r.status_code, r.text[:300])
