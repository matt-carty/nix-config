{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
  ];

  fileSystems."/mnt/usb4tb" = {
    device = "/dev/disk/by-uuid/a6b7c512-c01b-4882-9351-6da0a79777e5";
    fsType = "ext4";
    options = ["nofail"];
  };
  fileSystems."/mnt/usb8tb" = {
    device = "/dev/disk/by-uuid/60a06020-6fb4-47de-9225-e4ad5ceb632b";
    fsType = "ext4";
    options = ["nofail"];
  };

  fileSystems."/mnt/storage" = {
    fsType = "fuse.mergerfs";
    device = "/mnt/usb8tb/:/mnt/usb4tb/";
    options = ["minfreespace=100G" "category.create=mfs"];
  };

  fileSystems."/export/flint" = {
    depends = ["/mnt/storage" "/export/flint"];
    device = "/mnt/storage/flint";
    options = ["bind"];
  };
  fileSystems."/export/stuff" = {
    depends = ["/mnt/storage" "/export/stuff"];
    device = "/mnt/storage/stuff";
    options = ["bind"];
  };
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.89.24.0/24(rw,fsid=0,no_subtree_check,no_root_squash) 10.89.42.0/24(rw,fsid=0,no_subtree_check,no_root_squash)
    /export/flint	10.89.24.0/24(rw,fsid=1,no_subtree_check,no_root_squash) 10.89.42.0/24(rw,fsid=1,no_subtree_check,no_root_squash)
    /export/stuff 10.89.24.0/24(rw,fsid=2,no_subtree_check) 10.89.42.0/24(rw,fsid=2,no_subtree_check)
  '';
  networking.firewall.enable = false;
}
