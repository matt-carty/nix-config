{ pkgs, inputs, ...}: {

environment.systemPackages = with pkgs; [
  mergerfs
  mergerfs-tools
  ];


fileSystems."/export/nextcloud" = {
    device = "/mnt/storage/nextcloud";
    options = [ "bind" ];
  };

fileSystems."/mnt/storage" = {
  fsType = "fuse.mergerfs";
  device = "/mnt/usb*";
  options = [ "minfreespace=100G" "category.create=mfs" ];
  };
}
