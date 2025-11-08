{
  inputs,
  pkgs,
  ...
}: let
  stable-pkgs = import inputs.nixpkgs-stable {
    system = pkgs.system;
    config = pkgs.config;
  };
in {
  environment.systemPackages = [
    stable-pkgs.input-leap
  ];
}
