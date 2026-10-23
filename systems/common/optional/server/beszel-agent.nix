# Thin wrapper around the native services.beszel.agent so every host
# reporting to tycho's beszel-hub shares the same HUB_URL default and
# sops-backed token convention, instead of repeating it per-host.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.beszelAgentClient;
in {
  options.services.beszelAgentClient = {
    enable = lib.mkEnableOption "beszel agent, reporting to tycho's hub";

    hubUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://tycho.skippy.crty.io:8090";
      description = "Beszel hub URL this agent registers with.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to an env-file containing `TOKEN=...` (e.g.
        `config.sops.secrets.beszel_agent_env.path`). Generate the token from
        the hub's web UI at http://tycho.skippy.crty.io:8090 (Settings -> Tokens
        for a universal token, or "Add System" for a per-host one).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.beszel.agent = {
      enable = true;
      environment.HUB_URL = cfg.hubUrl;
      environmentFile = cfg.tokenFile;
      # Hub has DISABLE_SSH=true, so it never dials back in -- no inbound
      # port needed on this host.
      openFirewall = false;
    };
  };
}
