{ ... }:{

fileSystems."/mnt/nextcloud" = {
    device = "bobbie:/nextcloud";
    fsType = "nfs";
};
fileSystems."/mnt/stuff" = {
    device = "bobbie:/stuff";
    fsType = "nfs";
};
fileSystems."/home/matt/docker/nextcloud/data/data" = {
    depends = [ "/mnt/nextcloud" ]; 
    device = "/mnt/nextcloud/data/data";
    options = [ "bind" ];
 };
}
