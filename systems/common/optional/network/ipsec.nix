{
  config,
  pkgs,
  lib,
  ...
}: {
  services.strongswan-swanctl = {
    enable = true;
  };

  # Create templated swanctl.conf with the secret injected
  sops.templates."swanctl.conf" = {
    content = ''
      authorities {
        skippy-ca {
          cacert = ${toString ./public_ipsec_certs/skippy_ipsec_ca.crt}
        }
      }

      connections {
        pfsense-mobile {
          remote_addrs = dukebk44.duckdns.org
          version = 2
          vips = 0.0.0.0

          local-main {
            auth = eap
            eap_id = alien
          }

          remote-main {
            auth = pubkey
            id = dukebk44.duckdns.org
          }

          children {
            pfsense-tunnel {
              local_ts = dynamic
              remote_ts = 0.0.0.0/0
              esp_proposals = aes128-sha256-modp2048
              dpd_action = restart
              rekey_time = 60m
              life_time = 66m
            }
          }

          proposals = aes256gcm16-sha256-modp4096
          rekey_time = 480m
          dpd_delay = 30s
          dpd_timeout = 150s
        }
      }

      secrets {
        eap-alien {
          id-main = alien
          secret = ${config.sops.placeholder.ipsec_password}
        }
      }
    '';
    owner = "root";
    mode = "0400";
  };

  # Override the swanctl config location
  environment.etc."swanctl/swanctl.conf".source = lib.mkForce config.sops.templates."swanctl.conf".path;

  environment.systemPackages = [pkgs.strongswan];

  sops.secrets.ipsec_password = {
    owner = "root";
    mode = "0400";
    restartUnits = ["strongswan-swanctl.service"];
  };
}
