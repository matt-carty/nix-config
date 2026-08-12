# Minimal first-boot image for tycho. Gets the Pi online and reachable over
# SSH; the real config in ./configuration.nix is deployed afterwards.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common/global/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "tycho";
    search = ["skippy.crty.io" "home.crty.io"];
    useDHCP = lib.mkDefault true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];

  boot.growPartition = true;
  sdImage.compressImage = false;

  system.stateVersion = "26.05";
}
