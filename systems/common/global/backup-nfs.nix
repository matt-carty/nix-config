{...}: {
  fileSystems."/mnt/backups" = {
    device = "ceres.skippy.crty.io:/mnt/main/backups";
    fsType = "nfs";
  };
}
