{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    snapraid
  ];

  # Mount the 6TB parity drive
  fileSystems."/mnt/parity6tb" = {
    device = "/dev/disk/by-uuid/YOUR-6TB-UUID-HERE";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/usb4tb" = {
    device = "/dev/disk/by-uuid/a6b7c512-c01b-4882-9351-6da0a79777e5";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/usb6tb" = {
    device = "/dev/disk/by-uuid/863d97a4-a6bb-4650-bb0a-670acac0f042";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/usb8tb" = {
    device = "/dev/disk/by-uuid/60a06020-6fb4-47de-9225-e4ad5ceb632b";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/usb8tb/:/mnt/usb4tb/";
    options = ["minfreespace=100G" "category.create=mfs"];
  };

  fileSystems."/export/flint" = {
    depends = ["/mnt/storage" "/export/flint"];
    device = "/mnt/storage/flint";
    options = ["bind"];
  };

  fileSystems."/export/stuff" = {
    depends = ["/mnt/storage" "/export/stuff"];
    device = "/mnt/storage/stuff";
    options = ["bind"];
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
    /export/flint	10.89.24.0/24(rw,fsid=1,no_subtree_check,no_root_squash) 10.89.42.0/24(rw,fsid=1,no_subtree_check,no_root_squash)
    /export/stuff 10.89.24.0/24(rw,fsid=2,no_subtree_check) 10.89.42.0/24(rw,fsid=2,no_subtree_check)
  '';

  networking.firewall.enable = false;
}
