{ pkgs, inputs, ...}: {

fileSystems."/export/nextcloud" = {
    device = "/mnt/storage/nextcloud";
    options = [ "bind" ];
  };
}
