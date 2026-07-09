{lib, ...}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
    ./common/features/claude-desktop.nix
    ./common/features/cursor-wrapper.nix
  ];

  # Customisations for matt@medina
  programs.kitty = {
    settings = {
      font_size = 11;
    };
  };

  # Quadro K2200 + nvidia 580 + Wayland: DPMS wake and suspend/resume are
  # unreliable. Keep the display always on and stop the power button from
  # triggering a broken suspend cycle.
  dconf.settings = {
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "nothing";
      sleep-inactive-ac-type = "nothing";
    };
  };
}
