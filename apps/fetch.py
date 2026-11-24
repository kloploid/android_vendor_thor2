#!/usr/bin/env python3
"""Downloads the latest release of each NineTailsFlip app into apps/prebuilt/ for the ROM build.

usage: vendor/thor2/apps/fetch.py

Reads each app's update.json from its latest GitHub release (the same file the apps' own
updater reads), takes the arm64-v8a APK if there is one, else the universal one, checks its
SHA-256, and saves it as prebuilt/<app>.apk. The APKs keep their release signature, so the
copies in the image update from GitHub like any installed copy.
"""
import hashlib
import json
import os
import sys
import time
import urllib.request

APPS = ["tg9", "g9", "l9", "c9", "p9", "m9"]
ABI = "arm64-v8a"
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "prebuilt")


def get(url, attempts=4):
    """GitHub's redirect to its release-asset storage sometimes times out once: retry."""
    request = urllib.request.Request(url, headers={"User-Agent": "thor2-rom-build"})
    for attempt in range(1, attempts + 1):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except OSError as e:
            if attempt == attempts:
                raise
            print(f"  retry {attempt}: {e}", file=sys.stderr)
            time.sleep(5 * attempt)


def main():
    os.makedirs(OUT, exist_ok=True)
    versions = []
    for app in APPS:
        info = json.loads(get(f"https://github.com/NineTailsFlip/{app}/releases/latest/download/update.json"))
        apks = {a["abi"]: a for a in info["apks"]}
        apk = apks.get(ABI) or apks.get("universal") or info["apks"][0]
        target = os.path.join(OUT, f"{app}.apk")
        if os.path.exists(target) and hashlib.sha256(open(target, "rb").read()).hexdigest() == apk["sha256"]:
            print(f"{app} {info['versionName']}: up to date")
        else:
            data = get(apk["url"])
            if hashlib.sha256(data).hexdigest() != apk["sha256"]:
                sys.exit(f"{app}: checksum mismatch for {apk['url']}")
            with open(target + ".part", "wb") as f:
                f.write(data)
            os.replace(target + ".part", target)
            print(f"{app} {info['versionName']}: {apk['abi']}, {len(data) // 1024} KB")
        versions.append(f"{app} {info['versionName']} ({info['versionCode']}) {apk['abi']} {apk['sha256']}")
    with open(os.path.join(OUT, "VERSIONS.txt"), "w") as f:
        f.write("\n".join(versions) + "\n")


if __name__ == "__main__":
    main()
