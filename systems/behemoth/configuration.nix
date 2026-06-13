# This is your system's configuration file.
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
    ./drives/storage.nix
    ./drives/snapraid.nix
    ../common/optional/network/ipsec.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "behemoth";

  nfsMounts.backup = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.tmp.useTmpfs = true;
  boot.kernel.sysctl = {
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  networking.search = ["skippy.crty.io" "home.crty.io"];
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [config.sops.secrets."parents_wifi.env".path];
      profiles = {
        "parents-wifi" = {
          connection.id = "parents-wifi";
          connection.type = "wifi";
          wifi.ssid = "$parents_ssid";
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$parents_psk";
          };
        };
      };
    };
  };

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  systemd.services.strongswan-initiate = {
    description = "Initiate strongSwan VPN connection";
    after = ["strongswan-swanctl.service"];
    wants = ["strongswan-swanctl.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 5 && (${pkgs.strongswan}/bin/swanctl --list-sas | grep -q pfsense-tunnel || ${pkgs.strongswan}/bin/swanctl --initiate --child pfsense-tunnel)'";
    };
  };
  systemd.timers.strongswan-initiate = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30min";
      Unit = "strongswan-initiate.service";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets."parents_wifi.env" = {};

  system.stateVersion = "26.05";
}
