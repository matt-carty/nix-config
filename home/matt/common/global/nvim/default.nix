{
  config,
  lib,
  pkgs,
  inputs,
  ...
  }: {


  home.packages = with pkgs; [ 
    lua-language-server
    stylua
    luajitPackages.luarocks
    lua
  ]; 
  
  programs.nixvim = {
    
    enable = true;

    # Nixvim plugins here
    plugins.bufferline.enable = true;
    plugins.dashboard.enable = true;
    plugins.dressing.enable = true;
    plugins.flash.enable = true;
    plugins.friendly-snippets.enable = true;
    plugins.gitsigns.enable = true;
    plugins.harpoon.enable = true;
    plugins.indent-blankline.enable = true;
    plugins.lualine.enable = true;
    plugins.telescope.enable = true;
    plugins.treesitter.enable = true;
    plugins.web-devicons.enable = true;
    plugins.which-key.enable = true;

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
    globals.mapleader = " "; # Sets the leader key to space
  };
}
