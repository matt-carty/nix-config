# This is your system's configuration file.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
    ../common/optional/desktop/desktop-apps.nix
    ../common/optional/desktop/fonts.nix
    ../common/optional/desktop/gnome-pi.nix
    ../common/optional/desktop/autologin.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "bobbie";

  nixpkgs.overlays = [
    # neovim-nightly-overlay.overlays.default
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
  ];
  nixpkgs.config.allowUnsupportedSystem = true;

  nfsMounts.backup = true;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.firewall.enable = false;

  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
    git
    gh
    libraspberrypi
    raspberrypi-eeprom
  ];

  system.stateVersion = "25.11";
}
