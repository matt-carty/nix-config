{
  ...
}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
  ];

  # Customisations for matt@alien
  programs.kitty = {
    settings = {
      font_size = 13;
    };
   };
}
