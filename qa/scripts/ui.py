"""adb UI driver for the Zaytona QA run.

  ui.py shot  <serial> <name>          screenshot -> shots/<name>.png (540px wide)
  ui.py dump  <serial> [all]           visible nodes with label + centre (clickable only unless 'all')
  ui.py tap   <serial> <x> <y>         tap device pixels
  ui.py tapq  <serial> <query> [n]     tap the n-th node whose text/desc contains query
  ui.py type  <serial> <text>          type ASCII text into the focused field
  ui.py key   <serial> <keycode>       e.g. BACK, ENTER, HOME
  ui.py swipe <serial> up|down
"""
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from io import BytesIO
from pathlib import Path

from PIL import Image

ADB = r"C:\Users\mmhd7\AppData\Local\Android\Sdk\platform-tools\adb.exe"
SHOTS = Path(__file__).parent / "shots"
SHOTS.mkdir(exist_ok=True)
sys.stdout.reconfigure(encoding="utf-8")


def adb(serial, *args, binary=False, timeout=60):
    out = subprocess.run([ADB, "-s", serial, *args], capture_output=True, timeout=timeout)
    return out.stdout if binary else out.stdout.decode("utf-8", "replace")


def shot(serial, name):
    png = adb(serial, "exec-out", "screencap", "-p", binary=True)
    img = Image.open(BytesIO(png)).convert("RGB")
    w, h = img.size
    img = img.resize((540, int(h * 540 / w)), Image.LANCZOS)
    path = SHOTS / f"{name}.png"
    img.save(path, optimize=True)
    print(path)


def nodes(serial):
    adb(serial, "shell", "uiautomator", "dump", "/sdcard/ui.xml")
    xml = adb(serial, "exec-out", "cat", "/sdcard/ui.xml")
    xml = xml[xml.find("<?xml"):]
    root = ET.fromstring(xml)
    out = []
    for n in root.iter("node"):
        b = re.findall(r"\d+", n.get("bounds", ""))
        if len(b) != 4:
            continue
        x1, y1, x2, y2 = map(int, b)
        if x2 <= x1 or y2 <= y1:
            continue
        label = (n.get("text") or "").strip() or (n.get("content-desc") or "").strip()
        out.append({
            "label": label.replace("\n", " / "), "cls": n.get("class", "").split(".")[-1],
            "click": n.get("clickable") == "true", "focus": n.get("focused") == "true",
            "x": (x1 + x2) // 2, "y": (y1 + y2) // 2, "bounds": (x1, y1, x2, y2),
            "checked": n.get("checked") == "true", "enabled": n.get("enabled") == "true",
        })
    return out


def dump(serial, show_all=False):
    for i, n in enumerate(nodes(serial)):
        if show_all or n["click"] or n["cls"] == "EditText":
            if not n["label"] and not n["click"] and n["cls"] != "EditText":
                continue
            flags = "".join(f for f, on in (("C", n["click"]), ("F", n["focus"]), ("x", n["checked"]),
                                            ("-", not n["enabled"])) if on)
            print(f"{i:3} {flags:3} {n['cls'][:12]:12} ({n['x']:4},{n['y']:4}) {n['label'][:90]}")


def tapq(serial, query, nth=0):
    q = query.lower()
    all_nodes = nodes(serial)
    hits = [n for n in all_nodes if n["label"].lower() == q] or [n for n in all_nodes if q in n["label"].lower()]
    if len(hits) <= nth:
        print(f"NOT FOUND: {query!r}")
        sys.exit(2)
    n = hits[nth]
    adb(serial, "shell", "input", "tap", str(n["x"]), str(n["y"]))
    print(f"tapped {n['label'][:60]!r} at ({n['x']},{n['y']})")


def main():
    cmd, serial, *rest = sys.argv[1:]
    if cmd == "shot":
        shot(serial, rest[0])
    elif cmd == "dump":
        dump(serial, bool(rest and rest[0] == "all"))
    elif cmd == "tap":
        adb(serial, "shell", "input", "tap", rest[0], rest[1])
        print("tapped", rest[0], rest[1])
    elif cmd == "tapq":
        tapq(serial, rest[0], int(rest[1]) if len(rest) > 1 else 0)
    elif cmd == "type":
        adb(serial, "shell", "input", "text", rest[0].replace(" ", "%s"))
        print("typed", rest[0])
    elif cmd == "key":
        adb(serial, "shell", "input", "keyevent", f"KEYCODE_{rest[0].upper()}")
        print("key", rest[0])
    elif cmd == "swipe":
        if rest[0] == "up":
            adb(serial, "shell", "input", "swipe", "540", "1800", "540", "700", "300")
        else:
            adb(serial, "shell", "input", "swipe", "540", "700", "540", "1800", "300")
        print("swiped", rest[0])
    time.sleep(0.2)


if __name__ == "__main__":
    main()
