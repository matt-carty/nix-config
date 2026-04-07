# ssh-watchdog-target.nix
# Import on the machine you want to self-reboot when SSH becomes unreachable.
#
# Usage in configuration.nix:
#
#   imports = [ ./ssh-watchdog-target.nix ];
#
#   services.sshWatchdogTarget = {
#     enable = true;
#     authorizedKeys = [
#       "ssh-ed25519 AAAA...key-for-server1 watchdog-server1"
#       "ssh-ed25519 AAAA...key-for-server2 watchdog-server2"
#     ];
#   };

{ config, lib, pkgs, ... }:

let
  cfg = config.services.sshWatchdogTarget;
  stampFile = "/var/lib/ssh-watchdog/stamp";
in {

  options.services.sshWatchdogTarget = {
    enable = lib.mkEnableOption "SSH watchdog target (self-reboots if stamp goes stale)";

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Public keys for the probing servers. The command= restriction is added
        automatically — each key will only be permitted to touch the stamp file.
      '';
      example = [ "ssh-ed25519 AAAA... watchdog-server1" ];
    };

    maxStampAge = lib.mkOption {
      type = lib.types.int;
      default = 3600;
      description = "How old (in seconds) the stamp file can be before triggering a reboot.";
    };

    checkInterval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often the watchdog timer runs (systemd time span syntax).";
    };

    bootGracePeriod = lib.mkOption {
      type = lib.types.str;
      default = "20min";
      description = ''
        How long after boot before the watchdog starts checking. Give your
        probing servers time to check in before the watchdog fires.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    # Dedicated unprivileged user — probing servers log in as this user
    users.users.ssh-watchdog = {
      isSystemUser = true;
      group = "ssh-watchdog";
      home = "/var/lib/ssh-watchdog";
      createHome = true;
      # Wrap every authorised key with the command= restriction so a
      # compromised key cannot do anything except touch the stamp file
      openssh.authorizedKeys.keys = map (key:
        ''command="touch ${stampFile}",no-pty,no-agent-forwarding,no-port-forwarding,no-X11-forwarding ${key}''
      ) cfg.authorizedKeys;
    };
    users.groups.ssh-watchdog = {};

    systemd.services.ssh-watchdog = {
      description = "Reboot if SSH heartbeat stamp is stale";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = let
          script = pkgs.writeShellScript "ssh-watchdog-check" ''
            STAMP="${stampFile}"
            MAX_AGE="${toString cfg.maxStampAge}"

            if [ ! -f "$STAMP" ]; then
              echo "ssh-watchdog: no stamp file yet (boot grace period), skipping"
              exit 0
            fi

            NOW=$(date +%s)
            MTIME=$(date -r "$STAMP" +%s)
            AGE=$(( NOW - MTIME ))

            echo "ssh-watchdog: stamp age ''${AGE}s, limit ''${MAX_AGE}s"

            if [ "$AGE" -gt "$MAX_AGE" ]; then
              echo "ssh-watchdog: stamp stale — rebooting now"
              systemctl reboot
            fi
          '';
        in "${script}";
      };
    };

    systemd.timers.ssh-watchdog = {
      description = "Periodically run the SSH watchdog check";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.bootGracePeriod;
        OnUnitActiveSec = cfg.checkInterval;
        Persistent = true;
      };
    };
  };
}
