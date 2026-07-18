{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
    ./common/features/claude-desktop.nix
    ./common/features/cursor-wrapper.nix
  ];

  # Customisations for matt@medina
  # nixpkgs' `graphify` lags upstream by ~3 months / 90 releases, including
  # several real security fixes (stored XSS in graph.html, SSRF guard race,
  # prompt-injection hardening, hook path validation). Pin to latest upstream
  # release instead: https://github.com/safishamsi/graphify/blob/v0.9.17/CHANGELOG.md
  home.packages = [
    (pkgs.graphify.overridePythonAttrs (old: rec {
      version = "0.9.17";
      src = pkgs.fetchFromGitHub {
        owner = "safishamsi";
        repo = "graphify";
        tag = "v${version}";
        hash = "sha256-APs6YPABAgf2DTGzUPTbMOkEC7O5JjmR4/HtBXA/ECI=";
      };
      dependencies =
        old.dependencies
        ++ (with pkgs.python3.pkgs; [numpy rapidfuzz])
        ++ (with pkgs.python3.pkgs.tree-sitter-grammars; [
          tree-sitter-groovy
          tree-sitter-fortran
          tree-sitter-bash
          tree-sitter-json
        ]);
      # nixpkgs' tree-sitter grammar packages float on their own versioning
      # and routinely fall outside graphify's declared bounds; the bounds
      # exist for upstream's PyPI wheels, not relevant to nix-built grammars.
      pythonRelaxDeps = true;
    }))
  ];

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
