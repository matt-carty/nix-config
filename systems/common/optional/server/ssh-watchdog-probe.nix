# ssh-watchdog-probe.nix
# Import on each server that should SSH into the Pi to touch the stamp file.
#
# Usage in configuration.nix:
#
#   imports = [ ./ssh-watchdog-probe.nix ];
#
#   services.sshWatchdogProbe = {
#     enable = true;
#     targets = [
#       {
#         host = "my-pi.example.com";
#         # Generate with:
#         #   ssh-keygen -t ed25519 -f /etc/ssh/ssh_watchdog_key -N "" -C "watchdog-$(hostname)"
#         # Then put the public key in the target machine's sshWatchdogTarget.authorizedKeys
#         privateKeyFile = "/etc/ssh/ssh_watchdog_key";
#       }
#     ];
#   };
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.sshWatchdogProbe;
in {
  options.services.sshWatchdogProbe = {
    enable = lib.mkEnableOption "SSH watchdog probe (touches stamp file on target machines)";

    targets = lib.mkOption {
      description = "List of machines to probe.";
      default = ["behemoth.jiba"];
      type = lib.types.listOf (lib.types.submodule {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            description = "Hostname or IP of the target machine.";
            example = "pi.example.com";
          };

          user = lib.mkOption {
            type = lib.types.str;
            default = "ssh-watchdog";
            description = "Username to connect as on the target.";
          };

          port = lib.mkOption {
            type = lib.types.int;
            default = 22;
            description = "SSH port on the target.";
          };

          privateKeyFile = lib.mkOption {
            type = lib.types.str;
            description = "Path to the private key used to authenticate with this target.";
            example = "/etc/ssh/ssh_watchdog_key";
          };
        };
      });
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "15min";
      description = "How often to touch the stamp file on each target (systemd time span syntax).";
    };

    connectTimeout = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "SSH connect timeout in seconds.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.targets != []) {
    # One service + timer pair per target
    systemd.services = lib.listToAttrs (map (target: let
        # Sanitise the host into a valid systemd unit name component
        safeName = lib.replaceStrings ["." ":" "@"] ["-" "-" "-"] target.host;
        unitName = "ssh-watchdog-probe-${safeName}";
      in {
        name = unitName;
        value = {
          description = "SSH watchdog probe → ${target.host}";
          serviceConfig = {
            Type = "oneshot";
            User = "root";
            ExecStart = let
              script = pkgs.writeShellScript "ssh-watchdog-probe-${safeName}" ''
                echo "ssh-watchdog-probe: touching stamp on ${target.user}@${target.host}:${toString target.port}"
                ${pkgs.openssh}/bin/ssh \
                  -i ${lib.escapeShellArg target.privateKeyFile} \
                  -p ${toString target.port} \
                  -o ConnectTimeout=${toString cfg.connectTimeout} \
                  -o BatchMode=yes \
                  -o StrictHostKeyChecking=yes \
                  -o PasswordAuthentication=no \
                  ${lib.escapeShellArg "${target.user}@${target.host}"}
                # No command needed — the target's authorized_keys command= runs touch automatically
              '';
            in "${script}";
            # Failure is fine — other probing servers will cover it
            SuccessExitStatus = "0 255";
          };
        };
      })
      cfg.targets);

    systemd.timers = lib.listToAttrs (map (target: let
        safeName = lib.replaceStrings ["." ":" "@"] ["-" "-" "-"] target.host;
        unitName = "ssh-watchdog-probe-${safeName}";
      in {
        name = unitName;
        value = {
          description = "Periodically probe ${target.host} for SSH watchdog";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = cfg.interval; # stagger first run to avoid boot pile-up
            OnUnitActiveSec = cfg.interval;
            Persistent = true;
          };
        };
      })
      cfg.targets);
  };
}
