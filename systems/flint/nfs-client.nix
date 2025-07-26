{...}: {
  fileSystems."/mnt/flint" = {
    device = "bobbie:/flint";
    fsType = "nfs";
  };
  fileSystems."/mnt/stuff" = {
    device = "bobbie:/stuff";
    fsType = "nfs";
  };
}
