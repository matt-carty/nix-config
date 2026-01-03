# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd
    inputs.sops-nix.nixosModules.sops
    # You can also split up your configuration and import pieces of it here:
    ../common/global/default.nix
    ../common/optional/desktop/desktop-apps.nix
    ../common/optional/desktop/fonts.nix
    ../common/optional/desktop/gnome.nix
    ../common/optional/desktop/printers.nix
    ../common/optional/desktop/autologin.nix
    ./mount-home.nix
    ../common/optional/network/ipsec.nix
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Graphics config
  boot.kernelParams = [
    #    "radeon.si_support=0"
    #    "radeon.cik_support=0"
    #    "amdgpu.si_support=1"
    #    "amdgpu.cik_support=1"
    #    "amdgpu.dc=1"
    #    "amdgpu.gpu_recovery=1"
    #    "amdgpu.ppfeaturemask=0xffffffff"
    #    "amdgpu.dpm=1"
  ];

  #  boot.initrd.kernelModules = ["amdgpu"];
  boot.blacklistedKernelModules = ["radeon"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    RADV_PERFTEST = "gpl";
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };
  hardware.firmware = [pkgs.linux-firmware];
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.search = ["skippy.crty.io" "home.crty.io"];
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable building for ARM
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # IPSEC config
  # Manual control on laptop - don't auto-start
  services.strongswan-swanctl.swanctl.connections.pfsense-mobile.children.pfsense-tunnel.start_action = lib.mkForce null;

  # Convenient aliases
  environment.shellAliases = {
    vpnup = "sudo swanctl --initiate --child pfsense-tunnel";
    vpndown = "sudo swanctl --terminate --ike pfsense-mobile";
    vpnstatus = "sudo swanctl --list-sas";
    vpnreload = "sudo swanctl --load-conns";
  };

  # SOPS Config
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/matt/.config/sops/age/keys.txt";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # TODO: Set your hostname
  networking.hostName = "alien";

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
