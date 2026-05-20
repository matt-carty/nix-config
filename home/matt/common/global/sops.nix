{config, pkgs, ...}: let
  ageKeyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
in {
  # CLI sops (editing secrets/secrets.yaml, scripts, etc.)
  home.packages = with pkgs; [
    sops
    age # age-keygen, age for local key management
  ];

  home.sessionVariables = {
    SOPS_EDITOR = "nvim";
    SOPS_AGE_KEY_FILE = ageKeyFile;
  };
}
