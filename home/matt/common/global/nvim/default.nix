{
  pkgs,
  ...
  }: {
  
  imports = [
    ./cmp.nix
    ];

  # required packages for plugins etc..
  home.packages = with pkgs; [ 
    lua-language-server
    stylua
    luajitPackages.luarocks
    lua
    ripgrep
  ]; 

  programs.nixvim = {
    
    enable = true;

    # Nixvim plugins here
    plugins.bufferline.enable = true;
    plugins.dashboard.enable = false; # Dont think I need dashboard
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
    plugins.neo-tree.enable = true;
    plugins.lint.enable = true;
    plugins.conform-nvim.enable = true;


    # Language server
    plugins.lsp = {
      enable = true;
      servers = {
        # Average webdev LSPs
        tsserver.enable = false; # TS/JS - causing error with LSP so disabled
        cssls.enable = true; # CSS
        tailwindcss.enable = true; # TailwindCSS
        html.enable = true; # HTML
        astro.enable = true; # AstroJS
        phpactor.enable = true; # PHP
        svelte.enable = false; # Svelte
        vuels.enable = false; # Vue
        pyright.enable = true; # Python
        marksman.enable = true; # Markdown
        nil-ls.enable = true; # Nix
        dockerls.enable = true; # Docker
        bashls.enable = true; # Bash
        clangd.enable = true; # C/C++
        csharp-ls.enable = true; # C#
        yamlls.enable = true; # YAML

        lua-ls = { # Lua
          enable = true;
          settings.telemetry.enable = false;
        };

        # Rust
        rust-analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
    };

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
  
    keymaps = [
      # Neo-tree bindings
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<leader>e";
      }
      # Telescope bindings
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<leader>ff";
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
		   key = "<leader>fw";
      }
    ];
  };

}
