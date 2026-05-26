# OpenClaw CLI on medina. The gateway runs on the ubuntu-openclaw VM, not here.
#
# Configure the CLI against that host (reserved IP / hostname on your router): URL, token,
# workspace paths, etc. per OpenClaw’s docs — e.g. a config under ~/.config/openclaw or env
# your shell exports from a local (non-Nix-managed) file.
#
# Starter workspace snippets if you bootstrap a fresh tree on the VM:
#   systems/medina/openclaw/seeds/
{...}: {
  programs.bash.shellAliases = {
    oc = "openclaw";
  };
}
