{...}: {
  fileSystems."/mnt/flint" = {
    device = "behemoth:/flint";
    fsType = "nfs";
  };
  fileSystems."/mnt/stuff" = {
    device = "behemoth:/stuff";
    fsType = "nfs";
  };
  fileSystems."/mnt/flint-test" = {
    device = "ceres:/mnt/main/flint";
    fsType = "nfs";
  };
}
