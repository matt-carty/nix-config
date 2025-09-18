{...}: {
  fileSystems."/mnt/photos_archive" = {
    device = "ceres.skippy.crty.io:/mnt/main/photos_archive";
    fsType = "nfs";
  };
  fileSystems."/mnt/stuff" = {
    device = "ceres.skippy.crty.io:/mnt/main/stuff";
    fsType = "nfs";
  };
}
