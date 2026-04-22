{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    snapraid
    hd-idle
    cryptsetup
    util-linux
  ];

  fileSystems."/mnt/usb4tb" = {
    device = "/dev/mapper/usb4tb-encrypted";
    fsType = "ext4";
    options = ["nofail" "noauto" "x-systemd.device-timeout=0"];
  };

  fileSystems."/mnt/parity6tb" = {
    device = "/dev/mapper/parity6tb-encrypted";
    fsType = "ext4";
    options = ["nofail" "noauto" "x-systemd.device-timeout=0"];
  };

  fileSystems."/mnt/usb8tb" = {
    device = "/dev/mapper/usb8tb-encrypted";
    fsType = "ext4";
    options = ["nofail" "noauto" "x-systemd.device-timeout=0"];
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/usb8tb/:/mnt/usb4tb/";
    options = ["nofail" "noauto" "x-systemd.device-timeout=0" "minfreespace=100G" "category.create=mfs"];
  };

  systemd.targets.external-storage = {
    description = "External encrypted storage drives";
  };

  systemd.services.storage-mount = {
    description = "Open LUKS devices and mount external storage";
    wantedBy = [];
    before = ["external-storage.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "120s";
      ExecStart = pkgs.writeShellScript "storage-mount" ''
                CRYPTSETUP="${pkgs.cryptsetup}/bin/cryptsetup"
                MOUNT="${pkgs.util-linux}/bin/mount"
                MOUNTPOINT="${pkgs.util-linux}/bin/mountpoint"
                MERGERFS="${pkgs.mergerfs}/bin/mergerfs"

                open_luks() {
                  local name="$1"
                  local uuid="$2"
                  local keyfile="$3"
                  local device="/dev/disk/by-uuid/$uuid"

                  if [ ! -e "$device" ]; then
                    echo "WARNING: Device $uuid not found, skipping $name"
                    return 1
                  fi

                  if [ -e "/dev/mapper/$name" ]; then
                    echo "$name already open"
                    return 0
                  fi

                  timeout 30 "$CRYPTSETUP" luksOpen "$device" "$name" --key-file "$keyfile" || {
                    echo "WARNING: Failed to open $name"
                    return 1
                  }
                }

                mount_fs() {
                  local mountpoint ="$1"
                  local device="$2"
                  local fstype="$3"
                  local opts="$4"

                  if [ "$fstype" != "fuse.mergerfs" ] && [ ! -e "$device" ]; then
                    echo "WARNING: $device not available, skipping $mountpoint"
                    return 1
                  fi

                  if $MOUNTPOINT -q "$mountpoint"; then
                    echo "$mountpoint already mounted"
                    return 0
                  fi

                  timeout 30 "$MOUNT" -t "$fstype" -o "$opts" "$device" "$mountpoint" || {
                    echo "WARNING: Failed to mount $mountpoint"
                    return 1
                  }
                }

                open_luks "usb8tb-encrypted"    "1d063486-a9dc-4b11-996a-786da4e3331b" "/root/luks-keys/usb8tb.key"    || true
                open_luks "usb4tb-encrypted"    "39f49560-a8ba-473b-a235-5a8af4993a11" "/root/luks-keys/usb4tb.key"    || true
                open_luks "parity6tb-encrypted" "f02f46c4-a3dc-462c-9f0c-5f4b3fb14db7" "/root/luks-keys/parity6tb.key" || true

                mount_fs "/mnt/usb8tb"    "/dev/mapper/usb8tb-encrypted"    "ext4" "nofail" || true
                mount_fs "/mnt/usb4tb"    "/dev/mapper/usb4tb-encrypted"    "ext4" "nofail" || true
                mount_fs "/mnt/parity6tb" "/dev/mapper/parity6tb-encrypted" "ext4" "nofail" || true

        if $MOUNTPOINT -q /mnt/usb8tb || $MOUNTPOINT -q /mnt/usb4tb; then
          timeout 30 "$MERGERFS" "/mnt/usb8tb:/mnt/usb4tb" "/mnt/storage" \
            -o "minfreespace=100G,category.create=mfs" || \
            echo "WARNING: Failed to mount mergerfs"
        else
          echo "WARNING: No data drives mounted, skipping mergerfs"
        fi
                echo "Storage mount complete"
      '';
      ExecStop = pkgs.writeShellScript "storage-umount" ''
        UMOUNT="${pkgs.util-linux}/bin/umount"
        CRYPTSETUP="${pkgs.cryptsetup}/bin/cryptsetup"

        $MOUNTPOINT -q /mnt/storage   && timeout 30 "$UMOUNT" /mnt/storage   || true
        $MOUNTPOINT -q /mnt/usb8tb    && timeout 30 "$UMOUNT" /mnt/usb8tb    || true
        $MOUNTPOINT -q /mnt/usb4tb    && timeout 30 "$UMOUNT" /mnt/usb4tb    || true
        $MOUNTPOINT -q /mnt/parity6tb && timeout 30 "$UMOUNT" /mnt/parity6tb || true

        [ -e /dev/mapper/usb8tb-encrypted ]    && timeout 30 "$CRYPTSETUP" luksClose usb8tb-encrypted    || true
        [ -e /dev/mapper/usb4tb-encrypted ]    && timeout 30 "$CRYPTSETUP" luksClose usb4tb-encrypted    || true
        [ -e /dev/mapper/parity6tb-encrypted ] && timeout 30 "$CRYPTSETUP" luksClose parity6tb-encrypted || true
      '';
    };
  };

  environment.etc."snapraid.conf".text = ''
    parity /mnt/parity6tb/snapraid.parity

    content /var/snapraid/snapraid.content
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

  systemd.tmpfiles.rules = [
    "d /var/snapraid 0755 root root -"
    "d /mnt/usb4tb 0755 root root -"
    "d /mnt/usb8tb 0755 root root -"
    "d /mnt/parity6tb 0755 root root -"
    "d /mnt/storage 0755 root root -"
    "f /var/log/hd-idle.log 0644 root root -"
  ];

  systemd.services.snapraid-sync = {
    description = "SnapRAID sync";
    requires = ["storage-mount.service"];
    after = ["storage-mount.service"];
    unitConfig = {
      ConditionPathIsMountPoint = "/mnt/usb8tb";
    };
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
    unitConfig = {
      ConditionPathIsMountPoint = "/mnt/usb8tb";
    };
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

  networking.firewall.enable = false;

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
