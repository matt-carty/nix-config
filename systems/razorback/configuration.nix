# This is your system's configuration file.
{pkgs, ...}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
    ../common/optional/desktop/fonts.nix
    ../common/optional/server/docker.nix
    #    ../common/optional/server/open-webui.nix
    ./unlock-luks.nix
    ./mount-ssd.nix
    ./docker-backup.nix
    ./mount-scooter.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "razorback";

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
    photosArchive = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["kvm.enable_virt_at_load=0"]; # temporary fix for virtualbox

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # N97/Alder Lake-N
      intel-compute-runtime # OpenCL support
      libva-vdpau-driver
      libvdpau-va-gl
      # Don't include vaapiIntel - it's for older GPUs and conflicts
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

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver instead of i965
  };
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
  ];

  system.stateVersion = "24.05";
}
