# This is your system's configuration file.
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    inputs.sops-nix.nixosModules.sops
    ../common/global/default.nix
    ../common/optional/nfs-shares.nix
    ../common/optional/desktop/audio.nix
    ../common/optional/desktop/desktop-apps.nix
    ../common/optional/desktop/fonts.nix
    ../common/optional/desktop/gnome.nix
    ../common/optional/desktop/printers.nix
    ../common/optional/desktop/autologin.nix
    ../common/optional/server/docker.nix
    ../common/optional/server/paperclip-docker.nix
    ./mount-home.nix
    ./libvirt-bridge-vm-host.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "medina";

  nixpkgs.overlays = [
    inputs.nix-openclaw.overlays.default
    # neovim-nightly-overlay.overlays.default
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
  ];

  nfsMounts = {
    backup = true;
    stuff = {
      enable = true;
      mountPoint = "/home/matt/stuff";
    };
    flint = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Quadro K2200 (Maxwell) is unsupported by 590+; needs legacy 580.
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.firewall.enable = false;

  services.xserver.videoDrivers = ["nvidia"];
  medinaLibvirtBridge.enable = true;
  services.usbmuxd.enable = true;

  # Read-only NFS export for ubuntu-openclaw VM (and any other host on the LAN subnet).
  services.nfs.server = {
    enable = true;
    exports = ''
      /home/matt/supreme_invention  10.89.24.0/24(ro,no_subtree_check)
    '';
  };

  services.paperclip-docker = {
    enable = true;
    host = "0.0.0.0";
    environmentFiles = [config.sops.secrets."paperclip-env".path];
    # Optional: pin image — image = "ghcr.io/paperclipai/paperclip:<tag-or-digest>";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    openclaw
    libimobiledevice
    ifuse
    solaar
    gnomeExtensions.solaar-extension
    libportal
    deskflow
  ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/matt/.config/sops/age/keys.txt";
  sops.secrets."paperclip-env" = {};

  system.stateVersion = "24.11";
}
