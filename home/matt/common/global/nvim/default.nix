{
  config,
  lib,
  pkgs,
  ...
  }: {

  home.packages = with pkgs; [ 
    lua-language-server
    stylua

  ]; 

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];


};
  xdg.configFile."nvim" = {
   source = ./config;
   recursive = true;
  };

}
