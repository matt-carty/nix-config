# Declarative Paperclip (https://github.com/paperclipai/paperclip) via Docker.
# Image publishes to ghcr.io/paperclipai/paperclip — pin `services.paperclip-docker.image`
# to a release tag or digest for reproducible deploys.
{
  config,
  lib,
  ...
}:
let
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
        inherit (cfg) image;
        ports = ["${cfg.host}:${toString cfg.port}:3100"];
        volumes = ["${cfg.dataDir}:/paperclip"];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 matt users - -"
    ];
  };
}
