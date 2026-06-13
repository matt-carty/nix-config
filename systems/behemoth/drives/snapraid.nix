{pkgs, ...}: {
  environment.systemPackages = [pkgs.snapraid];

  environment.etc."snapraid.conf".text = ''
    parity /mnt/parity6tb/snapraid.parity

    content /mnt/usb8tb/snapraid.content
    content /mnt/usb4tb/snapraid.content

    data d1 /mnt/usb8tb/
    data d2 /mnt/usb4tb/

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

    autosave 500
    block_size 256
  '';

  systemd.services.snapraid-sync = {
    description = "SnapRAID sync";
    requires = ["storage-mount.service"];
    after = ["storage-mount.service"];
    unitConfig.ConditionPathIsMountPoint = "/mnt/usb8tb";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.services.snapraid-scrub = {
    description = "SnapRAID scrub";
    requires = ["storage-mount.service"];
    after = ["storage-mount.service"];
    unitConfig.ConditionPathIsMountPoint = "/mnt/usb8tb";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapraid}/bin/snapraid scrub -p 8 -o 5";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.snapraid-sync = {
    description = "SnapRAID sync timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  systemd.timers.snapraid-scrub = {
    description = "SnapRAID scrub timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 03:00:00";
      Persistent = true;
    };
  };
}
