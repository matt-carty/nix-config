{pkgs, ...}: {
  environment.systemPackages = with pkgs; [restic];

  services.restic.backups = {
    razorbackdocker = {
      user = "root";
      repository = "/mnt/backups/razorback-docker";

      paths = ["/home/matt/docker"];

      # Just check the mount exists
      backupPrepareCommand = ''
        if ! ${pkgs.util-linux}/bin/mountpoint -q /mnt/backups; then
          echo "ERROR: /mnt/backups not mounted"
          exit 1
        fi
      '';

      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-hourly 24"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];

      passwordFile = "/etc/nixos/restic-password";
      initialize = true;
    };
  };

  # Make backup wait for network mount
  systemd.services."restic-backups-razorbackdocker".after = ["mnt-backups.mount"];
}
