{
  pkgs,
  ...
}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
  ];
  programs.bash = {
    enable = true;
    shellAliases = [
    hss = "home-manager switch --flake .#matt@alien"
    nrs = "sudo nixos-rebuild switch --flake .#alien"
    ];

}
