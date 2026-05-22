#!/usr/bin/env bash
# Add OpenClaw sops secrets from an existing ~/.openclaw setup.
# Usage: ./scripts/bootstrap-openclaw-secrets.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
SECRETS="$ROOT/secrets/secrets.yaml"
export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

if [[ ! -f "$CFG" ]]; then
  for candidate in \
    "$HOME/.openclaw/openclaw.json" \
    "/var/lib/openclaw/openclaw.json"; do
    if [[ -r "$candidate" ]]; then
      CFG="$candidate"
      break
    fi
  done
fi
CFG="${CFG:-}"

exec nix shell nixpkgs#python3 nixpkgs#sops --command env SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_FILE" python3 - "$CFG" "$SECRETS" <<'PY'
import json, os, subprocess, sys

cfg_path, secrets = sys.argv[1], os.path.abspath(sys.argv[2])

def read_existing_env(key):
    try:
        out = subprocess.check_output(
            ["sops", "-d", "--extract", json.dumps([key]), secrets],
        )
        return out.decode().strip()
    except subprocess.CalledProcessError:
        return ""

cfg = {}
if cfg_path and os.path.isfile(cfg_path):
    with open(cfg_path) as f:
        cfg = json.load(f)

gt = cfg.get("gateway", {}).get("auth", {}).get("token", "")
tg = cfg.get("channels", {}).get("telegram", {}).get("botToken", "")
existing_env = read_existing_env("openclaw-env")
if not gt and existing_env:
    for line in existing_env.splitlines():
        if line.startswith("OPENCLAW_GATEWAY_TOKEN="):
            gt = line.split("=", 1)[1]
            break
existing_tg = read_existing_env("openclaw-telegram-token")
if not tg and existing_tg:
    tg = existing_tg.strip()
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
    sys.exit("channels.telegram.botToken missing (config and openclaw-telegram-token secret)")
if not gt:
    sys.exit("gateway.auth.token missing (config and openclaw-env secret)")

env_body = "\n".join(dict.fromkeys(lines))
cli_env_body = f"OPENCLAW_GATEWAY_TOKEN={gt}\n" if gt else ""
subprocess.run(
    ["sops", "set", secrets, '["openclaw-telegram-token"]', json.dumps(tg)],
    check=True,
)
subprocess.run(
    ["sops", "set", secrets, '["openclaw-env"]', json.dumps(env_body)],
    check=True,
)
if cli_env_body:
    subprocess.run(
        ["sops", "set", secrets, '["openclaw-cli-env"]', json.dumps(cli_env_body.strip())],
        check=True,
    )
print(f"Updated {secrets} (openclaw-env, openclaw-cli-env, openclaw-telegram-token)")
PY
