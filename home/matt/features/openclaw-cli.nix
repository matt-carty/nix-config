# OpenClaw CLI env for the system gateway on medina.
# Gateway token is loaded from the nixos sops secret at shell startup.
{config, ...}: {
  home.sessionVariables = {
    OPENCLAW_STATE_DIR = "/var/lib/openclaw";
    OPENCLAW_CONFIG_PATH = "/etc/openclaw/openclaw.json";
    OPENCLAW_WORKSPACE_DIR = "/home/matt/openclaw/workspace";
  };

  programs.bash.initExtra = ''
    if [ -r /run/secrets/openclaw-cli-env ]; then
      set -a
      # shellcheck disable=SC1091
      . /run/secrets/openclaw-cli-env
      set +a
    fi
  '';

  programs.bash.shellAliases = {
    oc = "openclaw";
  };
}
