{
  config,
  lib,
  ...
}: let
  ceres = "ceres.skippy.crty.io";
  cfg = config.nfsMounts;
in {
  options.nfsMounts = {
    backup = lib.mkEnableOption "mount /mnt/backups from ceres";

    stuff = {
      enable = lib.mkEnableOption "mount ceres:/mnt/main/stuff";
      mountPoint = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/stuff";
      };
    };

    flint = lib.mkEnableOption "mount /mnt/flint from ceres";

    photosArchive = lib.mkEnableOption "mount /mnt/photos_archive from ceres";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.backup {
      fileSystems."/mnt/backups" = {
        device = "${ceres}:/mnt/main/backups";
        fsType = "nfs";
        options = ["nofail"];
      };
    })
    (lib.mkIf cfg.stuff.enable {
      fileSystems."${cfg.stuff.mountPoint}" = {
        device = "${ceres}:/mnt/main/stuff";
        fsType = "nfs";
      };
    })
    (lib.mkIf cfg.flint {
      fileSystems."/mnt/flint" = {
        device = "${ceres}:/mnt/main/flint";
        fsType = "nfs";
      };
    })
    (lib.mkIf cfg.photosArchive {
      fileSystems."/mnt/photos_archive" = {
        device = "${ceres}:/mnt/main/photos_archive";
        fsType = "nfs";
      };
    })
  ];
}
