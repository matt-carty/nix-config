{...}: {
  fileSystems."/mnt/flint-old" = {
    device = "behemoth:/flint";
    fsType = "nfs";
  };
  fileSystems."/mnt/stuff" = {
    device = "behemoth:/stuff";
    fsType = "nfs";
  };
  fileSystems."/mnt/flint" = {
    device = "ceres:/mnt/main/flint";
    fsType = "nfs";
  };
}
