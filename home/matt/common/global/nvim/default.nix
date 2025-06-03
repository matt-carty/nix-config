{pkgs, ...}: {
  imports = [
    ./cmp.nix
    ./keymaps.nix
  ];

  # required packages for plugins etc..
  home.packages = with pkgs; [
    lua-language-server
    stylua
    luajitPackages.luarocks
    lua
    ripgrep
    claude-code
  ];

  programs.nixvim = {
    enable = true;

    # Nixvim plugins here
    plugins.bufferline.enable = false;
    plugins.dashboard.enable = false; # Dont think I need dashboard
    plugins.dressing.enable = false;
    plugins.flash.enable = false;
    plugins.friendly-snippets.enable = false;
    plugins.gitsigns.enable = true;
    plugins.harpoon.enable = false;
    plugins.indent-blankline.enable = true;
    plugins.lualine.enable = true;
    plugins.telescope.enable = true;
    plugins.treesitter.enable = true;
    plugins.web-devicons.enable = true;
    plugins.which-key.enable = true;
    plugins.neo-tree.enable = true;
    plugins.conform-nvim.enable = false;
    plugins.todo-comments.enable = false;
    plugins.markdown-preview.enable = false;
    plugins.trouble.enable = false;

    plugins.toggleterm = {
      enable = true;
      settings = {
        open_mapping = "[[<C-t>]]";
      };
    };

    # Language server
    plugins.lsp = {
      enable = true;
      servers = {
        # Average webdev LSPs
        ts_ls.enable = true; # TS/JS - causing error with LSP so disabled
        cssls.enable = true; # CSS
        tailwindcss.enable = true; # TailwindCSS
        html.enable = true; # HTML
        phpactor.enable = true; # PHP
        vuels.enable = false; # Vue
        pyright.enable = true; # Python
        marksman.enable = true; # Markdown
        dockerls.enable = true; # Docker
        bashls.enable = true; # Bash
        clangd.enable = true; # C/C++
        csharp_ls.enable = true; # C#
        yamlls.enable = true; # YAML
        nixd = {
          enable = true;
          settings = {
            nixpkgs.expr = "import <nixpkgs>{}";
          };
        };
        lua_ls = {
          # Lua
          enable = true;
          settings.telemetry.enable = false;
        };
      };
    };

    # Non-nixvim plugins here

    # Colour schemes here
    colorschemes.rose-pine.enable = true;

    # Options here
    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      shiftwidth = 2; # Tab width should be 2
    };

    # Keymaps here
    globals.mapleader = " "; # Sets the leader key to space
  };
}
