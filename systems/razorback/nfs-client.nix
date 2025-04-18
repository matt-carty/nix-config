{ ... }:{

fileSystems."/mnt/nextcloud" = {
    device = "bobbie:/export/nextcloud";
    fsType = "nfs";
};
fileSystems."/mnt/stuff" = {
    device = "bobbie:/export/stuff";
    fsType = "nfs";
};
}
