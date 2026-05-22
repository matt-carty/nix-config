# OpenClaw gateway as a system systemd service (nix-openclaw).
# Secrets: sops keys openclaw-env, openclaw-cli-env, openclaw-telegram-token
{
  config,
  lib,
  pkgs,
  ...
}: let
  stateDir = "/var/lib/openclaw";
  workspaceRoot = "/home/matt/openclaw";
  workspaceDir = "${workspaceRoot}/workspace";
  telegramTokenFile = config.sops.secrets."openclaw-telegram-token".path;
  workspaceSeeds = pkgs.runCommand "openclaw-workspace-seeds" {
    preferLocalBuild = true;
  } ''
    cp -r ${./openclaw/seeds} $out
  '';
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

  # Matt-readable gateway token for the openclaw CLI (home-manager sources this).
  sops.secrets."openclaw-cli-env" = {
    owner = "matt";
    group = "users";
    mode = "0400";
  };

  users.users.matt.extraGroups = lib.mkAfter ["openclaw"];

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

      agents = {
        defaults = {
          workspace = workspaceDir;
          skipBootstrap = true;
          model.primary = "openrouter/free";
          models = {
            "openrouter/auto" = {
              alias = "OpenRouter";
            };
            "openrouter/free" = {};
          };
        };
        list = [
          {
            id = "main";
            default = true;
            workspace = workspaceDir;
            identity = {
              name = "Em-Jay";
              theme = "Honest, independent, hardworking";
              emoji = "🏈";
            };
          }
        ];
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
  '';

  # Live workspace under ~/openclaw/workspace — seed missing files only, never overwrite.
  system.activationScripts.openclaw-workspace = lib.stringAfter ["openclaw-migrate"] ''
    legacyWorkspace="${stateDir}/workspace"

    if [ ! -d ${workspaceDir} ] && [ -d "$legacyWorkspace" ]; then
      echo "Migrating OpenClaw workspace to ${workspaceDir}..."
      mkdir -p ${workspaceRoot}
      cp -a "$legacyWorkspace" ${workspaceDir}
    fi

    mkdir -p ${workspaceDir} ${stateDir}/agents

    for seed in ${workspaceSeeds}/*; do
      [ -f "$seed" ] || continue
      dest="${workspaceDir}/$(basename "$seed")"
      if [ ! -e "$dest" ]; then
        echo "Seeding OpenClaw workspace file: $(basename "$dest")"
        install -o openclaw -g openclaw -m 0664 "$seed" "$dest"
      fi
    done

    chown -R openclaw:openclaw ${workspaceRoot}
    find ${workspaceRoot} -type d -exec chmod 2775 {} \;
    find ${workspaceRoot} -type f -exec chmod 0664 {} \;

    # Gateway runs as openclaw; matt's home is 700 by default — grant traverse only.
    ${pkgs.acl}/bin/setfacl -m u:openclaw:--x /home/matt

    chown -R openclaw:openclaw ${stateDir}
    find ${stateDir} -type d -exec chmod 2770 {} \;
    find ${stateDir} -type f -exec chmod 0660 {} \;

    if [ -d ${stateDir}/agents ]; then
      for agentDir in ${stateDir}/agents/*; do
        [ -d "$agentDir" ] || continue
        agentId="$(basename "$agentDir")"
        if [ "$agentId" != "main" ]; then
          echo "Removing extra OpenClaw agent: $agentId"
          rm -rf "$agentDir"
        fi
      done
    fi

    for extraWorkspace in ${stateDir}/workspace-*; do
      [ -d "$extraWorkspace" ] || continue
      echo "Removing extra OpenClaw workspace: $extraWorkspace"
      rm -rf "$extraWorkspace"
    done
  '';
}
