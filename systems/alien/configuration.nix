# This is your system's configuration file.
{
  inputs,
  lib,
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
    ../common/optional/network/ipsec.nix
    ./mount-home.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "alien";

  nixpkgs.overlays = [
    # neovim-nightly-overlay.overlays.default
    # (final: prev: {
    #   hi = final.hello.overrideAttrs (oldAttrs: {
    #     patches = [ ./change-hello-to-hi.patch ];
    #   });
    # })
  ];

  nfsMounts.backup = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = ["radeon"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.firmware = [pkgs.linux-firmware];

  networking.networkmanager.enable = true;
  networking.search = ["skippy.crty.io" "home.crty.io"];

  # Manual control on laptop - don't auto-start
  services.strongswan-swanctl.swanctl.connections.pfsense-mobile.children.pfsense-tunnel.start_action = lib.mkForce null;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl";
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };
  environment.shellAliases = {
    vpnup = "sudo swanctl --initiate --child pfsense-tunnel";
    vpndown = "sudo swanctl --terminate --ike pfsense-mobile";
    vpnstatus = "sudo swanctl --list-sas";
    vpnreload = "sudo swanctl --load-conns";
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/matt/.config/sops/age/keys.txt";

  system.stateVersion = "25.05";
}
