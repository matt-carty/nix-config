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
    hms = "home-manager switch --flake .#matt@razorback";
    nrs = "sudo nixos-rebuild switch --flake .#razorback";
    };
    bashrcExtra = "eval ""$(zoxide init bash)""";
};
  
  programs.kitty = {
    settings = {
      font_size = 12;
    };
   };

}
