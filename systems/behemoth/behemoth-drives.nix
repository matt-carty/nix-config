{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    snapraid
    hd-idle
    cryptsetup
  ];

  boot.initrd.secrets = {
    "/keyfile-usb4tb" = "/root/luks-keys/usb4tb.key";
    "/keyfile-parity6tb" = "/root/luks-keys/parity6tb.key";
    "/keyfile-usb8tb" = "/root/luks-keys/usb8tb.key";
  };

  # LUKS encrypted filesystems with key files
  boot.initrd.luks.devices = {
    "usb4tb-encrypted" = {
      device = "/dev/disk/by-uuid/39f49560-a8ba-473b-a235-5a8af4993a11";
      keyFile = "/keyfile-usb4tb";
      preLVM = true;
      allowDiscards = true;
    };
    "parity6tb-encrypted" = {
      device = "/dev/disk/by-uuid/f02f46c4-a3dc-462c-9f0c-5f4b3fb14db7";
      keyFile = "/keyfile-parity6tb";
      preLVM = true;
      allowDiscards = true;
    };
    "usb8tb-encrypted" = {
      device = "/dev/disk/by-uuid/1d063486-a9dc-4b11-996a-786da4e3331b";
      keyFile = "/keyfile-usb8tb";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/mnt/usb4tb" = {
    device = "/dev/mapper/usb4tb-encrypted";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/parity6tb" = {
    device = "/dev/mapper/parity6tb-encrypted";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/usb8tb" = {
    device = "/dev/mapper/usb8tb-encrypted";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/usb8tb/:/mnt/usb4tb/";
    options = ["minfreespace=100G" "category.create=mfs"];
  };

  # SnapRAID configuration
  environment.etc."snapraid.conf".text = ''
    # Parity file location (on the 6TB drive)
    parity /mnt/parity6tb/snapraid.parity

    # Content file locations (should be on multiple drives for redundancy)
    content /var/snapraid/snapraid.content
    content /mnt/usb8tb/snapraid.content
    content /mnt/usb4tb/snapraid.content

    # Data disks
    data d1 /mnt/usb8tb/
    data d2 /mnt/usb4tb/

    # Exclude patterns (adjust as needed)
    exclude *.unrecoverable
    exclude /tmp/
    exclude /lost+found/
    exclude downloads/
    exclude appdata/
    exclude *.!sync
    exclude .AppleDouble
    exclude ._AppleDouble
    exclude .DS_Store
    exclude .Thumbs.db
    exclude .fseventsd
    exclude .Spotlight-V100
    exclude .TemporaryItems
    exclude .Trashes
    exclude .AppleDB

    # Autosave: store the state every N GB processed
    autosave 500

    # Block size in kiB (default 256)
    block_size 256
  '';

  # Create directory for content file
  systemd.tmpfiles.rules = [
    "d /var/snapraid 0755 root root -"
    "f /var/log/hd-idle.log 0644 root root -"
  ];

  # Systemd service for SnapRAID sync
  systemd.services.snapraid-sync = {
    description = "SnapRAID sync";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  # Systemd service for SnapRAID scrub
  systemd.services.snapraid-scrub = {
    description = "SnapRAID scrub";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapraid}/bin/snapraid scrub -p 8 -o 5";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  # Timer for daily sync (runs at 2 AM)
  systemd.timers.snapraid-sync = {
    description = "SnapRAID sync timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Timer for weekly scrub (runs on Sunday at 3 AM)
  systemd.timers.snapraid-scrub = {
    description = "SnapRAID scrub timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 03:00:00";
      Persistent = true;
    };
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.89.24.0/24(rw,fsid=0,no_subtree_check,no_root_squash) 10.89.42.0/24(rw,fsid=0,no_subtree_check,no_root_squash)
  '';

  networking.firewall.enable = false;

  # Create systemd service for hd-idle
  systemd.services.hd-idle = {
    description = "External HDD spin down daemon";
    wantedBy = ["multi-user.target"];
    after = ["local-fs.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a sda -i 600 -a sdb -i 600 -a sdc -i 600 -l /var/log/hd-idle.log";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
