{ pkgs, ...}: {

environment.systemPackages = with pkgs; [
  mergerfs
  mergerfs-tools
  ];


fileSystems."/mnt/usb4tb" =  {
  device = "/dev/disk/by-uuid/a6b7c512-c01b-4882-9351-6da0a79777e5";   
  fsType = "ext4";
  options = [ "nofail" ];
};
fileSystems."/mnt/usb8tb" =  {
  device = "/dev/disk/by-uuid/60a06020-6fb4-47de-9225-e4ad5ceb632b";   
  fsType = "ext4";
  options = [ "nofail" ];
};

fileSystems."/mnt/storage" = {
  fsType = "fuse.mergerfs";
  device = [ "/mnt/usb8tb/" "/mnt/usb4tb/" ];
  options = [ "minfreespace=100G" "category.create=mfs" ];
  };

#fileSystems."/export/nextcloud" = {
#    device = "/mnt/storage/nextcloud";
#    options = [ "bind" ];
#  };
}
