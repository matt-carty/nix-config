# Claude Desktop + Grok Bot live in a Debian 12 distrobox ("ai-apps"). The box and the
# apps inside it are imperative; this module only ships the assemble manifest and a
# weekly update timer. Both apps update through apt (claude-desktop.list and the
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
in {
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
    Unit.Description = "Weekly ai-apps distrobox update";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
