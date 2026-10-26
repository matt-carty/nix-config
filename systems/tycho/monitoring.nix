# Fleet monitoring: Gatus for "is it up / is it green", Beszel hub for host metrics.
#
# Deliberately NOT hosted on razorback -- a razorback outage would take out
# visibility into the razorback outage.
{
  config,
  pkgs,
  ...
}: let
  # Poll intervals. Hosts are cheap to check; the TrueNAS API calls are not,
  # so they run less often.
  hostInterval = "1m";
  apiInterval = "5m";

  # TrueNAS SCALE's REST API (which the ceres checks below used to poll
  # directly) is fully removed in TrueNAS 26 -- replaced by a JSON-RPC 2.0
  # API that's WebSocket-only, which gatus's HTTP endpoint checker can't
  # speak. gatus's documented answer for exactly this situation is its
  # "external endpoint" push type (also used by the restic heartbeats
  # below): something else does the real check and reports pass/fail in.
  # This script is that something else -- runs on a timer, does the WS
  # JSON-RPC calls, pushes results to gatus.
  #
  # Also fixes a real bug the old REST check had: TrueNAS's alert.list
  # includes dismissed alerts too (each tagged `dismissed: true/false`),
  # but the old condition (`len([BODY]) == 0`) counted all of them, so a
  # dismissed alert could still leave the check red. This filters properly.
  truenasChecker = pkgs.writers.writePython3Bin "truenas-gatus-checks" {
    libraries = [pkgs.python3Packages.websockets];
  } ''
    import json
    import os
    import urllib.parse
    import urllib.request
    from websockets.sync.client import connect

    TRUENAS_API_KEY = os.environ["TRUENAS_API_KEY"]
    TOKEN = os.environ["CERES_CHECKS_TOKEN"]
    GATUS = "http://127.0.0.1:8080"


    def rpc(ws, id_, method, params=None):
        req = {
            "jsonrpc": "2.0",
            "id": id_,
            "method": method,
            "params": params or [],
        }
        ws.send(json.dumps(req))
        while True:
            msg = json.loads(ws.recv())
            if msg.get("id") == id_:
                if "error" in msg:
                    raise RuntimeError(f"{method}: {msg['error']}")
                return msg["result"]


    def push(key, success, error=None):
        status = "true" if success else "false"
        url = f"{GATUS}/api/v1/endpoints/{key}/external?success={status}"
        if error:
            url += "&error=" + urllib.parse.quote(error)
        headers = {"Authorization": f"Bearer {TOKEN}"}
        req = urllib.request.Request(url, method="POST", headers=headers)
        urllib.request.urlopen(req, timeout=10).close()


    def check(key, fn):
        try:
            ok, err = fn()
            push(key, ok, err)
        except Exception as e:
            push(key, False, str(e)[:200])


    def main():
        hub_url = "wss://ceres.skippy.crty.io/api/current"
        with connect(hub_url) as ws:
            rpc(ws, 1, "auth.login_with_api_key", [TRUENAS_API_KEY])

            def pool_check():
                pools = rpc(ws, 2, "pool.query")
                bad = [p["name"] for p in pools if p.get("status") != "ONLINE"]
                if bad:
                    return False, f"not ONLINE: {', '.join(bad)}"
                return True, None

            def alerts_check():
                alerts = rpc(ws, 3, "alert.list")
                undismissed = [a for a in alerts if not a.get("dismissed")]
                if undismissed:
                    return False, f"{len(undismissed)} undismissed alert(s)"
                return True, None

            def rsync_check():
                # Job states: WAITING, RUNNING, SUCCESS, FAILED, ABORTED.
                # Only the last two are actual failures -- a job that's
                # currently RUNNING (or queued WAITING) hasn't failed, it's
                # just mid-flight. Checking state == "SUCCESS" would flag
                # the task red for the entire duration it's actively
                # copying, not just when something goes wrong.
                tasks = rpc(ws, 4, "rsynctask.query")
                bad = [
                    t.get("id")
                    for t in tasks
                    if (t.get("job") or {}).get("state") in ("FAILED", "ABORTED")
                ]
                if bad:
                    return False, f"task(s) failed: {bad}"
                return True, None

            check("storage_ceres-zfs-pool", pool_check)
            check("storage_ceres-alerts", alerts_check)
            check("backups_offsite-rsync-(ceres-->-behemoth)", rsync_check)


    if __name__ == "__main__":
        main()
  '';

  # Reused by every endpoint so alerts are configured in one place.
  alerts = [
    {
      type = "email";
      enabled = true;
      failure-threshold = 3;
      success-threshold = 2;
      send-on-resolved = true;
    }
  ];

  hostCheck = name: address: {
    inherit name alerts;
    group = "hosts";
    url = "icmp://${address}";
    interval = hostInterval;
    conditions = ["[CONNECTED] == true"];
  };
in {
  services.gatus = {
    enable = true;
    openFirewall = true;

    # SMTP password + TrueNAS API key are interpolated from here as ${VAR}.
    environmentFile = config.sops.secrets.gatus_env.path;

    settings = {
      web.port = 8080;

      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
      };

      # Route through the mailrise instance already running on razorback,
      # rather than configuring a second notification path.
      alerting.email = {
        from = "gatus@skippy.crty.io";
        host = "razorback.skippy.crty.io";
        port = 8025;
        to = "monitoring@skippy.crty.io";
      };

      endpoints = [
        (hostCheck "ceres (TrueNAS)" "ceres.skippy.crty.io")
        (hostCheck "razorback" "razorback.skippy.crty.io")
        (hostCheck "behemoth" "behemoth.jiba")
        (hostCheck "medina" "medina.skippy.crty.io")

        # ceres pool/alerts/rsync checks moved to external-endpoints below --
        # see truenasChecker.

        # --- services on razorback --------------------------------------
        {
          inherit alerts;
          name = "homepage";
          group = "services";
          # DNS alias not live yet as of 2026-10-23 -- will go green once set up.
          url = "https://home.crty.io/";
          interval = hostInterval;
          conditions = ["[STATUS] == 200"];
        }
        {
          inherit alerts;
          name = "immich";
          group = "services";
          url = "https://photos.crty.io/api/server/ping";
          interval = hostInterval;
          conditions = ["[STATUS] == 200"];
        }
      ];

      # Push-based, for jobs that cannot be polled. A cron job that silently
      # stopped firing is indistinguishable from one that never existed, so
      # these go red when nothing reports in within the heartbeat window.
      external-endpoints = [
        {
          inherit alerts;
          name = "restic razorback-docker";
          group = "backups";
          token = "\${RESTIC_BACKUP_TOKEN}";
          heartbeat.interval = "90m"; # hourly job + slack
        }
        {
          inherit alerts;
          name = "restic razorback-docker prune";
          group = "backups";
          token = "\${RESTIC_PRUNE_TOKEN}";
          heartbeat.interval = "26h"; # daily job + slack
        }

        # Pushed by truenasChecker (systemd timer below) over JSON-RPC/WS,
        # not polled directly -- see the comment on truenasChecker for why.
        {
          inherit alerts;
          name = "ceres zfs pool";
          group = "storage";
          token = "\${CERES_CHECKS_TOKEN}";
          heartbeat.interval = "15m"; # checker runs every 5m
        }
        {
          inherit alerts;
          name = "ceres alerts";
          group = "storage";
          token = "\${CERES_CHECKS_TOKEN}";
          heartbeat.interval = "15m";
        }
        {
          inherit alerts;
          # Name/group must match exactly -- truenasChecker hardcodes the
          # gatus key this derives into ("backups_offsite-rsync-(ceres-->-behemoth)").
          name = "offsite rsync (ceres -> behemoth)";
          group = "backups";
          token = "\${CERES_CHECKS_TOKEN}";
          heartbeat.interval = "15m";
        }
      ];
    };
  };

  systemd.services.truenas-gatus-checks = {
    description = "Push ceres TrueNAS health to gatus over JSON-RPC/WebSocket";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${truenasChecker}/bin/truenas-gatus-checks";
      EnvironmentFile = config.sops.secrets.gatus_env.path;
      DynamicUser = true;
    };
  };

  systemd.timers.truenas-gatus-checks = {
    description = "Run truenas-gatus-checks on the same cadence gatus used to poll ceres directly";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = apiInterval;
      Persistent = true;
    };
  };

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
    # dataDir defaults to /var/lib/beszel-hub, which is bind-mounted to the SSD.

    # Agents connect out to the hub over WebSocket (HUB_URL+TOKEN) rather
    # than the hub dialing back in over SSH. Means no inbound port needs
    # opening on every monitored host -- see common/optional/server/beszel-agent.nix.
    environment.DISABLE_SSH = "true";
  };

  networking.firewall.allowedTCPPorts = [8090];

  sops.secrets.gatus_env = {
    # gatus runs as DynamicUser, so the unit reads this before dropping privs.
    owner = "root";
    mode = "0400";
    # Without this, rotating the secret's content doesn't restart gatus --
    # sops-nix only restarts a unit on rotation if told to, so the service
    # keeps running with whatever it loaded at its last start.
    restartUnits = ["gatus.service"];
  };
}
