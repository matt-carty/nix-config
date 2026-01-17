{...}: {
  fileSystems."/home/matt/stuff" = {
    device = "ceres:/mnt/main/stuff";
    fsType = "nfs";
  };
}
