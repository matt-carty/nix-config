{
  ...
}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
  ]; 

  # Customisations for matt@razorback
  programs.kitty = {
    settings = {
      font_size = 11;
    };
   };

}
