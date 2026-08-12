# tycho -- dedicated fleet monitoring host (Raspberry Pi).
{...}: {
  imports = [
    ../common/global/default.nix
    ../common/optional/server/ssh-watchdog-target.nix
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
    device = "/dev/disk/by-uuid/REPLACE-WITH-USB-SSD-UUID";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=30"];
  };

  fileSystems."/var/lib/gatus" = {
    device = "/mnt/ssd/gatus";
    fsType = "none";
    options = ["bind" "nofail"];
    depends = ["/mnt/ssd"];
  };

  fileSystems."/var/lib/beszel-hub" = {
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
