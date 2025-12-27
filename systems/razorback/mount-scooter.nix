{...}: {
  fileSystems."/mnt/scooter/" = {
    device = "/dev/disk/by-uuid/f76b84ab-58f4-41c4-88db-54641ea5e15e";
    fsType = "ext4";
  };
}
