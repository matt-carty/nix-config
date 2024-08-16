# Need the stuff to make it work as a module (took this from M77)
{
  pkgs,
  inputs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ../common/global
    ../common/users/matt.nix
    ../common/workstation
  ];

  # Networking
  networking.hostName = "homevm";
  networking.networkmanager.enable = true;

  # Boot
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk=true;

  # Programs that are specifically only on this machine

  # State Version
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

}
