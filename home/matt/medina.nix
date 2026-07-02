{...}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
    ./common/features/cursor-wrapper.nix
  ];

  # Customisations for matt@medina
  programs.kitty = {
    settings = {
      font_size = 11;
    };
  };
}
