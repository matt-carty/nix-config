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
    shellAliases = {
    hms = "home-manager switch --flake .#matt@alien";
    nrs = "sudo nixos-rebuild switch --flake .#alien";
    };
  };
  programs.kitty = {
    settings = {
      font_size = 13;
    };
   };
}
