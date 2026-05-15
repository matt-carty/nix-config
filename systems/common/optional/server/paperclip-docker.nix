# Declarative Paperclip (https://github.com/paperclipai/paperclip) via Docker.
# Image publishes to ghcr.io/paperclipai/paperclip — pin `services.paperclip-docker.image`
# to a release tag or digest for reproducible deploys.
{
  config,
  lib,
  ...
}: let
  cfg = config.services.paperclip-docker;
in {
  options.services.paperclip-docker = {
    enable = lib.mkEnableOption "Paperclip AI agent orchestration (Docker)";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/paperclipai/paperclip:latest";
      description = "OCI image reference; prefer a version tag or @sha256:… for reproducibility.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/paperclip";
      description = "Host directory mounted at /paperclip (PAPERCLIP_HOME in the image).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to bind the published port (127.0.0.1 keeps it off the LAN).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3100;
      description = "Host port mapped to the container UI/API (3100 in the upstream image).";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = ''
        Extra `--env-file` paths for the container (Docker `environmentFiles`).
        Use for root-owned files such as `config.sops.secrets.… .path`; file contents
        must be env-file format (`KEY=value` lines, e.g. `BETTER_AUTH_SECRET=…`).

        For Claude Code subscription login (`claude /login`), do not set
        `CLAUDE_CODE_OAUTH_TOKEN` or `CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST` here —
        they override the on-disk credential store and go stale. Use `ANTHROPIC_API_KEY`
        only if you want API-key auth instead of subscription login.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable || config.virtualisation.podman.enable;
        message = "services.paperclip-docker needs virtualisation.docker.enable or virtualisation.podman.enable.";
      }
    ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.paperclip = {
        inherit (cfg) image environmentFiles;
        # Do not set `user` — the image entrypoint switches to `node` (1000:1000) itself.
        environment = {
          # Persist Claude Code under the bind mount via ~/.claude (do not set
          # CLAUDE_CONFIG_DIR — it can write credentials to a literal ~/ subdir in cwd).
          HOME = "/paperclip";
          PAPERCLIP_HOME = "/paperclip";
        };
        ports = ["${cfg.host}:${toString cfg.port}:3100"];
        volumes = ["${cfg.dataDir}:/paperclip"];
      };
    };

    systemd.tmpfiles.rules = [
      # uid 1000 = matt on the host and `node` in the image; gid 100 = `users` on the host.
      # The container matches by uid (owner), not by group — do not use the docker group here.
      "d ${cfg.dataDir} 0750 1000 100 - -"
      "d ${cfg.dataDir}/.claude 0750 1000 100 - -"
    ];
  };
}
