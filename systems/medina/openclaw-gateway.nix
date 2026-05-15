# OpenClaw gateway as a system systemd service (nix-openclaw).
# Secrets: sops keys openclaw-env and openclaw-telegram-token in secrets/secrets.yaml
{
  config,
  lib,
  pkgs,
  ...
}: let
  stateDir = "/var/lib/openclaw";
  workspaceDir = "${stateDir}/workspace";
  telegramTokenFile = config.sops.secrets."openclaw-telegram-token".path;
in {
  sops.secrets."openclaw-env" = {
    owner = "openclaw";
    group = "openclaw";
    mode = "0400";
  };

  sops.secrets."openclaw-telegram-token" = {
    owner = "openclaw";
    group = "openclaw";
    mode = "0400";
  };

  services.openclaw-gateway = {
    enable = true;
    package = pkgs.openclaw;

    environmentFiles = [
      config.sops.secrets."openclaw-env".path
    ];

    servicePath = with pkgs; [
      git
      curl
      jq
      nodejs_22
      ripgrep
      nix
    ];

    config = {
      gateway = {
        mode = "local";
        port = 18789;
        bind = "loopback";
        auth.mode = "token";
        tailscale = {
          mode = "off";
          resetOnExit = false;
        };
        nodes.denyCommands = [
          "camera.snap"
          "camera.clip"
          "screen.record"
          "contacts.add"
          "calendar.add"
          "reminders.add"
          "sms.send"
          "sms.search"
        ];
      };

      agents.defaults = {
        workspace = workspaceDir;
        model.primary = "openrouter/free";
        models = {
          "openrouter/auto" = {
            alias = "OpenRouter";
          };
          "openrouter/free" = {};
        };
      };

      session.dmScope = "per-channel-peer";

      tools = {
        profile = "coding";
        web.search = {
          enabled = true;
          provider = "duckduckgo";
        };
      };

      plugins.entries = {
        openrouter.enabled = true;
        telegram.enabled = true;
        duckduckgo.enabled = true;
      };

      auth.profiles."openrouter:default" = {
        provider = "openrouter";
        mode = "api_key";
      };

      channels.telegram = {
        enabled = true;
        tokenFile = telegramTokenFile;
        groups."*" = {
          requireMention = true;
        };
      };

      commands.ownerAllowFrom = [
        "telegram:8227376301"
      ];

      hooks.internal = {
        enabled = true;
        entries.boot-md.enabled = true;
      };

      skills.install.nodeManager = "npm";
    };
  };

  # One-time migration from user onboarding (~/.openclaw) to the system state dir.
  system.activationScripts.openclaw-migrate = lib.stringAfter ["users" "specialfs"] ''
    if [ -d /home/matt/.openclaw/agents ] && [ ! -d ${stateDir}/agents ]; then
      echo "Migrating OpenClaw state from /home/matt/.openclaw to ${stateDir}..."
      mkdir -p ${stateDir}
      cp -a /home/matt/.openclaw/. ${stateDir}/
      chown -R openclaw:openclaw ${stateDir}
    fi
    mkdir -p ${workspaceDir}
    chown openclaw:openclaw ${workspaceDir}
  '';
}
