# Fleet monitoring: Gatus for "is it up / is it green", Beszel hub for host metrics.
#
# Deliberately NOT hosted on razorback -- a razorback outage would take out
# visibility into the razorback outage.
{config, ...}: let
  # Poll intervals. Hosts are cheap to check; the TrueNAS API calls are not,
  # so they run less often.
  hostInterval = "1m";
  apiInterval = "5m";

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
        (hostCheck "holden" "holden.skippy.crty.io")

        # --- ceres: real state, not just reachability -------------------
        # TrueNAS SCALE's v2.0 API is authenticated with an API key created
        # in the web UI (Credentials -> Local Users -> API Keys).
        {
          inherit alerts;
          name = "ceres zfs pool";
          group = "storage";
          url = "https://ceres.skippy.crty.io/api/v2.0/pool";
          interval = apiInterval;
          headers.Authorization = "Bearer \${TRUENAS_API_KEY}";
          conditions = [
            "[STATUS] == 200"
            "[BODY][0].status == ONLINE"
          ];
        }
        {
          inherit alerts;
          name = "ceres alerts";
          group = "storage";
          url = "https://ceres.skippy.crty.io/api/v2.0/alert/list";
          interval = apiInterval;
          headers.Authorization = "Bearer \${TRUENAS_API_KEY}";
          conditions = [
            "[STATUS] == 200"
            # No un-dismissed alerts. Verify against a real response body.
            "len([BODY]) == 0"
          ];
        }
        {
          inherit alerts;
          name = "offsite rsync (ceres -> behemoth)";
          group = "backups";
          url = "https://ceres.skippy.crty.io/api/v2.0/rsynctask";
          interval = apiInterval;
          headers.Authorization = "Bearer \${TRUENAS_API_KEY}";
          conditions = [
            "[STATUS] == 200"
            "[BODY][0].job.state == SUCCESS"
          ];
        }

        # --- services on razorback --------------------------------------
        # PLACEHOLDER URLs -- I could not verify ports or paths. Fill in from
        # your homepage config, which already has every one of these.
        {
          inherit alerts;
          name = "homepage";
          group = "services";
          url = "https://home.skippy.crty.io/";
          interval = hostInterval;
          conditions = ["[STATUS] == 200"];
        }
        {
          inherit alerts;
          name = "immich";
          group = "services";
          url = "https://immich.skippy.crty.io/api/server/ping";
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
      ];
    };
  };

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
    # dataDir defaults to /var/lib/beszel-hub, which is bind-mounted to the SSD.
  };

  networking.firewall.allowedTCPPorts = [8090];

  sops.secrets.gatus_env = {
    # gatus runs as DynamicUser, so the unit reads this before dropping privs.
    owner = "root";
    mode = "0400";
  };
}
