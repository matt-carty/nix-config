{
  config,
  pkgs,
  ...
}: let
  repository = "/mnt/backups/razorback-docker";
  # Was /etc/nixos/restic-password, which existed only on razorback's disk --
  # losing that disk made the offsite repo on behemoth unrecoverable.
  passwordFile = config.sops.secrets.restic_password.path;

  # Just check the mount exists
  requireMount = ''
    if ! ${pkgs.util-linux}/bin/mountpoint -q /mnt/backups; then
      echo "ERROR: /mnt/backups not mounted"
      exit 1
    fi
  '';
in {
  environment.systemPackages = with pkgs; [restic];

  sops.secrets.restic_password = {
    owner = "root";
    mode = "0400";
  };

  services.restic.backups = {
    # Append-only: no prune here. ceres rsyncs this repo offsite to behemoth
    # at 02:01, and prune deletes/repacks files in data/ which makes that
    # rsync see files vanish mid-transfer. Backups only ever add files, so
    # they are safe to run alongside a copy; prune is not.
    razorbackdocker = {
      user = "root";
      inherit repository passwordFile;

      paths = [
        "/home/matt/docker"
      ];

      backupPrepareCommand = requireMount;

      # Wait rather than fail if the daily prune below is still holding the
      # repo lock when the next hourly run starts.
      extraBackupArgs = ["--retry-lock=20m"];

      # Hourly, skipping the 02:01 offsite rsync window.
      timerConfig = {
        OnCalendar = "*-*-* 00,01,04..23:00:00";
        Persistent = true;
      };

      initialize = true;
    };

    # Prune-only job (no paths => the module emits just forget --prune),
    # scheduled well clear of the offsite rsync.
    razorbackdocker-prune = {
      user = "root";
      inherit repository passwordFile;

      paths = [];

      backupPrepareCommand = requireMount;

      pruneOpts = [
        "--retry-lock=20m"
        "--keep-hourly 24"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 12:30:00";
        Persistent = true;
      };
    };
  };

  # Make backup wait for network mount
  systemd.services."restic-backups-razorbackdocker".after = ["mnt-backups.mount"];
  systemd.services."restic-backups-razorbackdocker-prune".after = ["mnt-backups.mount"];
}
