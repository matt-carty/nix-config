{ ... }:{

fileSystems."/mnt/nextcloud" = {
    device = "bobbie:/nextcloud";
    fsType = "nfs";
};
fileSystems."/mnt/stuff" = {
    device = "bobbie:/stuff";
    fsType = "nfs";
};
}
