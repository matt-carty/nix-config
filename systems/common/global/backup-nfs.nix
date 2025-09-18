{...}: {
  fileSystems."/mnt/backups" = {
    device = "ceres:/mnt/main/backups";
    fsType = "nfs";
  };
}
