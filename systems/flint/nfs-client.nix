{...}: {
  fileSystems."/mnt/flint" = {
    device = "behemoth:/flint";
    fsType = "nfs";
  };
  fileSystems."/mnt/stuff" = {
    device = "behemoth:/stuff";
    fsType = "nfs";
  };
}
