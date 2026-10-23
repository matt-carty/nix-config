# tycho -- dedicated fleet monitoring host (Raspberry Pi).
{config, ...}: {
  imports = [
    ../common/global/default.nix
    ../common/optional/server/ssh-watchdog-target.nix
    ../common/optional/server/ssh-watchdog-probe.nix
    ./monitoring.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "tycho";
  networking.search = ["skippy.crty.io" "home.crty.io"];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.tmp.useTmpfs = true;

  services.sshWatchdogTarget = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO50FO03p5VLyV/PGZfEccVcH3iKJLyFyN4fL9tgoF3y watchdog-razorback"
    ];
  };

  sops.secrets.ssh_watchdog_tycho_key = {
    owner = "root";
    mode = "0400";
  };

  # Second prober for behemoth's watchdog stamp, alongside razorback's —
  # keeps behemoth's stamp fresh even when razorback is flaking.
  services.sshWatchdogProbe = {
    enable = true;
    targets = [
      {
        host = "behemoth.jiba";
        privateKeyFile = config.sops.secrets.ssh_watchdog_tycho_key.path;
      }
    ];
  };

  # Probe uses StrictHostKeyChecking=yes; pin behemoth's host key system-wide.
  programs.ssh.knownHosts."behemoth.jiba" = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfGKm8gtbxtT8gpKEsmQzBnIcjhvSFlmU2IkVTadrw+";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # --- keep writes off the SD card ------------------------------------
  # Gatus writes a row per check per endpoint and the Beszel hub is a
  # continuously-writing PocketBase/SQLite store. On an SD card that is a
  # wear-out path, and a monitoring host that dies quietly is the one
  # failure nothing else in the fleet is watching for.
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/55fab441-4149-4050-abef-a82ffcb3ad5a";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=30"];
  };

  # Both services run with DynamicUser + StateDirectory, which makes systemd
  # itself own /var/lib/<name> by bind-mounting it from /var/lib/private/<name>
  # into the unit's namespace. Bind-mounting the SSD onto /var/lib/<name>
  # directly collides with that -- systemd fails with "Device or resource
  # busy" trying to migrate an already-mounted path. Mount onto the private
  # path instead and let systemd's own machinery bind it onward from there.
  fileSystems."/var/lib/private/gatus" = {
    device = "/mnt/ssd/gatus";
    fsType = "none";
    options = ["bind" "nofail"];
    depends = ["/mnt/ssd"];
  };

  fileSystems."/var/lib/private/beszel-hub" = {
    device = "/mnt/ssd/beszel-hub";
    fsType = "none";
    options = ["bind" "nofail"];
    depends = ["/mnt/ssd"];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/ssd/gatus 0700 root root -"
    "d /mnt/ssd/beszel-hub 0700 root root -"
  ];

  # Journal to RAM as well -- same reasoning as behemoth.
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  system.stateVersion = "26.05";
}
