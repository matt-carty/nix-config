# Weekly live partclone of the root filesystem → /mnt/storage/behemoth-sd/
# TrueNAS (ceres) pulls current/ via an existing data-protection job.
#
# Layout:
#   /mnt/storage/behemoth-sd/inprogress/  write here, then promote
#   /mnt/storage/behemoth-sd/current/     newest complete image
#   /mnt/storage/behemoth-sd/previous/    prior generation (2 gens total)
#
# Restore (approx):
#   1. Partition the new card with current/partition-table.sfdisk
#   2. zstd -d -c current/root.pcl.zst | partclone.ext4 -r -o /dev/XXX -s -
#   3. Swap the card at the remote site
{
  pkgs,
  ...
}: let
  stageRoot = "/mnt/storage/behemoth-sd";
  partclone = "${pkgs.partclone}/bin/partclone.ext4";
  zstd = "${pkgs.zstd}/bin/zstd";
  findmnt = "${pkgs.util-linux}/bin/findmnt";
  lsblk = "${pkgs.util-linux}/bin/lsblk";
  sfdisk = "${pkgs.util-linux}/bin/sfdisk";
  backupScript = pkgs.writeShellScript "behemoth-sd-card-backup" ''
    set -euo pipefail

    STAGE="${stageRoot}"
    INPROGRESS="$STAGE/inprogress"
    CURRENT="$STAGE/current"
    PREVIOUS="$STAGE/previous"

    if ! ${pkgs.util-linux}/bin/mountpoint -q /mnt/storage; then
      echo "behemoth-sd-backup: /mnt/storage not mounted — aborting"
      exit 1
    fi

    ROOT_SRC="$(${findmnt} -n -o SOURCE /)"
    if [ -z "$ROOT_SRC" ] || [ ! -b "$ROOT_SRC" ]; then
      echo "behemoth-sd-backup: could not resolve block device for / (got: ''${ROOT_SRC:-empty})"
      exit 1
    fi

    PKNAME="$(${lsblk} -no PKNAME "$ROOT_SRC" | head -n1 | tr -d '[:space:]')"
    if [ -z "$PKNAME" ]; then
      echo "behemoth-sd-backup: could not resolve parent disk for $ROOT_SRC"
      exit 1
    fi
    PARENT="/dev/$PKNAME"

    echo "behemoth-sd-backup: imaging $ROOT_SRC (disk $PARENT) → $INPROGRESS"

    rm -rf "$INPROGRESS"
    mkdir -p "$INPROGRESS"

    ${sfdisk} -d "$PARENT" > "$INPROGRESS/partition-table.sfdisk"

    # -c clone, -I ignore fschk (required for live mounted root), -q quiet for journal
    ${partclone} -c -I -q -s "$ROOT_SRC" -o - \
      | ${zstd} -T0 -3 -f -o "$INPROGRESS/root.pcl.zst"

    {
      echo "hostname=$(hostname)"
      echo "finished_at=$(date -Is)"
      echo "root_source=$ROOT_SRC"
      echo "parent_disk=$PARENT"
      echo "root_uuid=$(${findmnt} -n -o UUID / || true)"
      echo "image_bytes=$(stat -c %s "$INPROGRESS/root.pcl.zst")"
    } > "$INPROGRESS/META"

    sync -f "$INPROGRESS"

    rm -rf "$PREVIOUS"
    if [ -d "$CURRENT" ]; then
      mv "$CURRENT" "$PREVIOUS"
    fi
    mv "$INPROGRESS" "$CURRENT"
    mkdir -p "$INPROGRESS"

    echo "behemoth-sd-backup: promoted to $CURRENT ($(stat -c %s "$CURRENT/root.pcl.zst") bytes)"
  '';
in {
  environment.systemPackages = [pkgs.partclone pkgs.zstd];

  systemd.services.behemoth-sd-card-backup = {
    description = "Partclone root SD image to /mnt/storage for TrueNAS pull";
    requires = ["storage-mount.service"];
    after = ["storage-mount.service"];
    unitConfig.ConditionPathIsMountPoint = "/mnt/storage";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = backupScript;
      Nice = 19;
      IOSchedulingClass = "idle";
      # Imaging a live root on a Pi can take a while
      TimeoutStartSec = "6h";
    };
  };

  systemd.timers.behemoth-sd-card-backup = {
    description = "Weekly behemoth SD card image";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 04:30:00";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
