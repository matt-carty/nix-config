#!/usr/bin/env bash
# Add OpenClaw sops secrets from an existing ~/.openclaw setup.
# Usage: ./scripts/bootstrap-openclaw-secrets.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
SECRETS="$ROOT/secrets/secrets.yaml"
export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

if [[ ! -f "$CFG" ]]; then
  echo "Missing $CFG — run openclaw onboard first or set OPENCLAW_CONFIG." >&2
  exit 1
fi

exec nix shell nixpkgs#python3 nixpkgs#sops --command python3 - "$CFG" "$SECRETS" <<'PY'
import json, os, subprocess, sys

cfg_path, secrets = sys.argv[1], sys.argv[2]
with open(cfg_path) as f:
    cfg = json.load(f)

gt = cfg.get("gateway", {}).get("auth", {}).get("token", "")
tg = cfg.get("channels", {}).get("telegram", {}).get("botToken", "")
sk = cfg.get("skills", {}).get("entries", {}).get("openai-whisper-api", {}).get("apiKey", "")

lines = []
if gt:
    lines.append(f"OPENCLAW_GATEWAY_TOKEN={gt}")
if sk:
    lines.append(f"OPENAI_API_KEY={sk}")

creds_dir = os.path.join(os.path.dirname(cfg_path), "credentials")
if os.path.isdir(creds_dir):
    for root, _, files in os.walk(creds_dir):
        for name in files:
            if "openrouter" in name.lower():
                p = os.path.join(root, name)
                try:
                    val = open(p).read().strip()
                    if val:
                        lines.append(f"OPENROUTER_API_KEY={val}")
                        break
                except OSError:
                    pass

if not tg:
    sys.exit("channels.telegram.botToken missing from config")
if not gt:
    sys.exit("gateway.auth.token missing from config")

env_body = "\n".join(dict.fromkeys(lines))
subprocess.run(["sops", "--set", '["openclaw-telegram-token"]', tg, secrets], check=True)
subprocess.run(["sops", "--set", '["openclaw-env"]', env_body, secrets], check=True)
print(f"Updated {secrets} (openclaw-env, openclaw-telegram-token)")
PY
