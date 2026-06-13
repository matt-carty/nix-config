# This is your system's configuration file.
{...}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
#    ../common/optional/desktop/desktop-apps.nix
#    ../common/optional/desktop/fonts.nix
#    ../common/optional/desktop/gnome.nix
#    ../common/optional/desktop/printers.nix
#    ../common/optional/desktop/autologin.nix
#    ../common/optional/server/docker.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "holden";

  nfsMounts.backup = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.05";
}
