# Detects filesystem drift inside running containers that CPU-based
# monitoring (Beszel) can't see -- a quiet backdoor or implant that never
# spikes CPU leaves no trace there, but `docker diff` catches any write to
# a container's writable layer regardless of how quiet it stays. This is
# what would have caught the Plausible/linuxsys dropper on day one instead
# of 9 days later: it wrote a new file to /var/tmp, which shows up
# immediately as an "A" (added) entry in `docker diff`, before it ever
# executed or touched CPU.
#
# The first time a container is seen, its current diff is recorded as the
# accepted baseline without alerting -- otherwise every container with
# days of legitimate non-volume-mounted writes (temp files, caches) would
# fire once on rollout. Only diff lines appearing after that baseline
# trigger a Telegram alert.
#
# Known blind spot: a container recreated for a legitimate reason (image
# bump, secret rotation) gets a fresh silent baseline on its next run -- a
# compromise landing in that exact window would blend into the new
# baseline instead of alerting. Beszel's CPU alerting is the backstop for
# anything that also burns CPU; this is for the quieter cases.
{
  config,
  pkgs,
  ...
}: let
  stateDir = "/var/lib/docker-diff";

  checker = pkgs.writers.writePython3Bin "docker-diff-check" {} ''
    import json
    import os
    import pathlib
    import subprocess
    import urllib.request

    STATE_DIR = pathlib.Path("${stateDir}")


    def docker(*args):
        return subprocess.run(
            ["docker", *args], capture_output=True, text=True, check=True
        ).stdout


    def running_containers():
        output = docker("ps", "--format", "{{.Names}}")
        return [name for name in output.splitlines() if name]


    def notify(text):
        token = os.environ["TELEGRAM_BOT_TOKEN"]
        chat_id = os.environ["TELEGRAM_CHAT_ID"]
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        data = json.dumps({"chat_id": chat_id, "text": text}).encode()
        req = urllib.request.Request(
            url, data=data, headers={"Content-Type": "application/json"}
        )
        urllib.request.urlopen(req, timeout=10).close()


    def main():
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        alerts = []

        for name in running_containers():
            diff = docker("diff", name).strip()
            lines = {line for line in diff.splitlines() if line}
            state_file = STATE_DIR / f"{name}.known"

            if not state_file.exists():
                # First time we've seen this container (fresh deploy, or
                # fresh install of this checker) -- record current state
                # as the accepted baseline rather than alerting on it.
                state_file.write_text("\n".join(sorted(lines)))
                continue

            known = {line for line in state_file.read_text().splitlines() if line}
            new = lines - known
            if new:
                alerts.append((name, sorted(new)))
                state_file.write_text("\n".join(sorted(known | new)))

        if alerts:
            parts = ["⚠️ docker diff: unexpected filesystem change(s) detected"]
            for name, new in alerts:
                parts.append(f"\n{name}:")
                for line in new[:20]:
                    parts.append(f"  {line}")
                if len(new) > 20:
                    parts.append(f"  ... and {len(new) - 20} more")
            notify("\n".join(parts))


    if __name__ == "__main__":
        main()
  '';
in {
  systemd.services.docker-diff-check = {
    description = "Alert on unexpected filesystem changes inside running containers";
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${checker}/bin/docker-diff-check";
      EnvironmentFile = [config.sops.secrets.gatus_env.path];
      StateDirectory = "docker-diff";
      User = "root"; # needs the docker socket
    };
  };

  systemd.timers.docker-diff-check = {
    description = "Run docker-diff-check every 15 minutes";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "15m";
      Persistent = true;
    };
  };
}
