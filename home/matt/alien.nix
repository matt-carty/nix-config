{
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
    hms = "home-manager switch --flake .#matt@$(hostname)";
    nrs = "sudo nixos-rebuild switch --flake .#$(hostname)";
    };
  };
  programs.kitty = {
    settings = {
      font_size = 13;
    };
   };
}
