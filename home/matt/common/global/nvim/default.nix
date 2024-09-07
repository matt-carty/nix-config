{
  config,
  pkgs,
  ...
  }: {

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
  home.file."${config.xdg.configHome}/nvim" = {
   source = ./config;
   recursive = true;
  };

}
