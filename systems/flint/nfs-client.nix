{...}: {
  fileSystems."/mnt/stuff" = {
    device = "ceres:/mnt/main/stuff";
    fsType = "nfs";
  };
  fileSystems."/mnt/flint" = {
    device = "ceres:/mnt/main/flint";
    fsType = "nfs";
  };
}
