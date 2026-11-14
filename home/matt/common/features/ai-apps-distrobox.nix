# Claude Desktop + Grok Bot live in a Debian 12 distrobox ("ai-apps"). The box and the
# apps inside it are imperative; this module only ships the assemble manifest and a
# daily update timer. Both apps update through apt (claude-desktop.list and the
# grok-bot.sources entry the grok-bot .deb registers itself). Host needs podman + distrobox (see systems/medina/configuration.nix).
#
# Create: distrobox assemble create --file ~/.config/distrobox/ai-apps.ini
{pkgs, ...}: let
  distrobox = "${pkgs.distrobox}/bin/distrobox";
  update = pkgs.writeShellScript "ai-apps-update" ''
    set -euo pipefail
    ${distrobox} enter ai-apps -- sudo apt-get update
    ${distrobox} enter ai-apps -- sudo apt-get upgrade -y
  '';
  # The box inherits the host PATH and can see /nix/store, so a bare `claude-desktop` would run
  # the host's Nix build, and the host LD_LIBRARY_PATH (nix alsa-lib) breaks Debian binaries.
  run = app: "${pkgs.distrobox}/bin/distrobox-enter -n ai-apps -- env -u LD_LIBRARY_PATH PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin /usr/bin/${app} --ozone-platform=wayland";
in {
  # Replace the files `distrobox-export` writes to ~/.local/share/applications (delete those, they
  # shadow these). Icons still come from distrobox-export (~/.local/share/icons/hicolor).
  xdg.desktopEntries = {
    "ai-apps-com.anthropic.Claude" = {
      name = "Claude (on ai-apps)";
      genericName = "AI Assistant";
      comment = "Desktop application for Claude.ai";
      exec = "${run "claude-desktop"} %U";
      icon = "claude-desktop";
      categories = ["Utility" "Development"];
      mimeType = ["x-scheme-handler/claude" "application/vnd.anthropic.mcpb" "application/vnd.anthropic.skill"];
      settings = {
        Keywords = "AI;Chat;Assistant;Claude;Code;LLM;";
        StartupWMClass = "com.anthropic.Claude";
        SingleMainWindow = "true";
      };
      actions = {
        NewChat = {
          name = "New Chat";
          exec = ''${run "claude-desktop"} "claude://claude.ai/new?surface=chat&source=desktop_action"'';
        };
        NewCode = {
          name = "New Claude Code Session";
          exec = ''${run "claude-desktop"} "claude://code/new?source=desktop_action"'';
        };
      };
    };
    "ai-apps-grok-bot" = {
      name = "Grok Bot (on ai-apps)";
      comment = "Grok Bot desktop agent";
      exec = "${run "grok-bot"} -- %U";
      icon = "grok-bot";
      categories = ["Development"];
      mimeType = ["x-scheme-handler/grokbot" "x-scheme-handler/sand"];
      settings.StartupWMClass = "grok-bot";
    };
  };

  xdg.configFile."distrobox/ai-apps.ini".source = ./ai-apps.ini;
  # docker is also installed on medina; make distrobox's choice explicit.
  xdg.configFile."distrobox/distrobox.conf".text = ''
    container_manager="podman"
  '';

  systemd.user.services.ai-apps-update = {
    Unit.Description = "Update apt packages and Grok Bot in the ai-apps distrobox";
    Service = {
      Type = "oneshot";
      # podman needs newuidmap (setuid wrapper) and the system profile.
      Environment = "PATH=/run/wrappers/bin:/run/current-system/sw/bin";
      ExecStart = "${update}";
    };
  };

  systemd.user.timers.ai-apps-update = {
    Unit.Description = "Daily ai-apps distrobox update";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
