{
  config,
  lib,
  pkgs,
  nixvim,
  ...
  }: {

  home.packages = with pkgs; [ 
    lua-language-server
    stylua
    luajitPackages.luarocks
    lua
  ]; 
  
  programs.nixvim = {
    

    # Nixvim plugins here
    plugins.bufferline.enable = true;
    plugins.dashboard.enable = true;
    plugins.dressing.enable = true;
    plugins.flash.enable = true;
    plugins.frienly-snippets.enable = true;
    plugins.gitsigns.enable = true;
    plugins.harpoon.enable = true;
    plugins.indent-blankline.enable = true;

    # Non-nixvim plugins here


    # Colour schemes here
    colorschemes.rose-pine.enable = true;
    
    # Options here
    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2;        # Tab width should be 2
    };
    
    # Keymaps here
    globals.mapleader = ","; # Sets the leader key to comma
  }
}
