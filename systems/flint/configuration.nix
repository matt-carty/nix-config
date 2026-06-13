# This is your system's configuration file.
{pkgs, ...}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
    ../common/optional/server/docker.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "flint";

  nixpkgs.overlays = [
    # neovim-nightly-overlay.overlays.default
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
  ];

  nfsMounts = {
    backup = true;
    stuff.enable = true;
    flint = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    # Note: hardware.graphics is correct for NixOS 25.11
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver # Essential for 4th gen Haswell
      libva-vdpau-driver
      libvdpau-va-gl
      # Remove intel-media-driver - it's for Broadwell (5th gen) and newer only
      # Remove intel-compute-runtime - not needed for basic VA-API on 4th gen
    ];
  };

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.firewall.enable = false;
  networking.networkmanager.appendNameservers = ["10.89.24.1"];

  services.printing.enable = true;
  services.usbmuxd.enable = true;

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
  ];

  system.stateVersion = "25.05";
}
