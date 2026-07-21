{
  lib,
  pkgs,
  ...
}: let
  # nixpkgs' `graphify` lags upstream by ~3 months / 90 releases, including
  # several real security fixes (stored XSS in graph.html, SSRF guard race,
  # prompt-injection hardening, hook path validation). Pin to latest upstream
  # release instead: https://github.com/safishamsi/graphify/blob/v0.9.17/CHANGELOG.md
  graphifyPinned = pkgs.graphify.overridePythonAttrs (old: rec {
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
  });

  # graphify's installer (install.py: _install_skill_references) stages the
  # packaged references/ sidecar by shutil.copytree()-ing it out of the Nix
  # store into ~/.<platform>/skills/graphify/references(.tmp), and copytree
  # preserves the store's read-only mode onto the copy. Its own cleanup
  # rmtree() then can't unlink files in a dir it can't write to, so every
  # future install/update/uninstall crashes with PermissionError. Fix from
  # the outside: chmod -R u+w any already-installed graphify skill dir
  # (every platform graphify supports, not just claude) before invoking the
  # real binary.
  graphifySkillDirSuffixes = [
    ".claude/skills/graphify"
    ".codex/skills/graphify"
    ".config/opencode/skills/graphify"
    ".config/kilo/skills/graphify"
    ".copilot/skills/graphify"
    ".openclaw/skills/graphify"
    ".factory/skills/graphify"
    ".trae/skills/graphify"
    ".trae-cn/skills/graphify"
    ".hermes/skills/graphify"
    ".pi/agent/skills/graphify"
    ".codebuddy/skills/graphify"
    ".agents/skills/graphify"
    ".config/agents/skills/graphify"
    ".gemini/skills/graphify"
    ".gemini/config/skills/graphify"
    ".kimi/skills/graphify"
    ".config/devin/skills/graphify"
    ".kiro/skills/graphify"
    ".aider/graphify"
  ];
  graphifyWrapped = pkgs.writeShellScriptBin "graphify" ''
    for root in "$HOME" "$PWD"; do
      ${lib.concatMapStringsSep "\n    " (suffix: ''
        [ -d "$root/${suffix}" ] && chmod -R u+w "$root/${suffix}" 2>/dev/null
      '')
      graphifySkillDirSuffixes}
    done
    if [ -n "''${CLAUDE_CONFIG_DIR:-}" ] && [ -d "$CLAUDE_CONFIG_DIR/skills/graphify" ]; then
      chmod -R u+w "$CLAUDE_CONFIG_DIR/skills/graphify" 2>/dev/null
    fi
    exec ${graphifyPinned}/bin/graphify "$@"
  '';

  # The bundled skill's Step 1 bootstrap falls back to a bare `python3` with
  # graphify importable when `uv` is missing and the wrapped binary's own
  # shebang isn't a Python interpreter either (both true here: no uv on
  # PATH, and nixpkgs wires graphify's deps into its wrapper's interpreter
  # at runtime via site.addsitedir rather than exposing a dedicated
  # per-app interpreter). Give the skill a real python3 with graphify
  # importable so that fallback actually resolves.
  graphifyPython = pkgs.python3.withPackages (ps: [(ps.toPythonModule graphifyPinned)]);
in {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
    ./common/features/claude-desktop.nix
    ./common/features/cursor-wrapper.nix
  ];

  # Customisations for matt@medina
  home.packages = [
    graphifyWrapped
    graphifyPython
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
