{lib, pkgs, config, ...}: {
  # snacks.lazygit() invokes `lazygit` from PATH and writes a theme to stdpath("cache")
  home.packages = [pkgs.lazygit];

  home.activation.nvimCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${config.xdg.cacheHome}/nvim"
  '';
  imports = [
    ./plugins.nix
    ./keymaps.nix
    ./lazy-plugins.nix
  ];

  programs.neovim.defaultEditor = true;

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        globals = {
          mapleader = " ";
          maplocalleader = "\\";
        };

        opts = {
          number = true;
          relativenumber = true;
          signcolumn = "yes";
          wrap = false;
          shiftwidth = 2;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          trouble.enable = true;
          lspkind.enable = true;
          presets.tailwindcss-language-server.enable = true;
          servers.nixd.settings = lib.generators.mkLuaInline ''
            (function()
              local hostname = vim.fn.hostname()
              return {
                nixd = {
                  nixpkgs = {
                    expr = 'import (builtins.getFlake "/home/matt/nix-config").inputs.nixpkgs { }',
                  },
                  options = {
                    nixos = {
                      expr = '(builtins.getFlake "/home/matt/nix-config").nixosConfigurations.' .. hostname .. '.options',
                    },
                    home_manager = {
                      expr = '(builtins.getFlake "/home/matt/nix-config").homeConfigurations."matt@' .. hostname .. '".options',
                    },
                  },
                },
              }
            end)()
          '';
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;

          nix = {
            enable = true;
            lsp.servers = ["nixd"];
          };
          markdown.enable = true;
          typescript.enable = true;
          lua.enable = true;
          html.enable = true;
          css.enable = true;
          sql.enable = true;
          rust.enable = true;
        };

        assistant = {
          codecompanion-nvim = {
            enable = true;
            setupOpts.adapters = lib.generators.mkLuaInline ''
              {
               openrouter_claude = function()
                 return require("codecompanion.adapters").extend("openai_compatible", { env = { url = "https://openrouter.ai/api", api_key = "OPENROUTER_API_KEY", chat_url = "/v1/chat/completions", }, schema = { model = { default = "anthropic/claude-sonnet-4", }, }, })
               end
              }
            '';
            setupOpts.strategies.chat.adapter = "openrouter_claude";
          };
        };

        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };

        autocomplete = {
          blink-cmp.enable = true;
        };

        statusline = {
          lualine = {
            enable = true;
            theme = "auto";
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        # Temporarily disable until nvf/tree-sitter-context catches up
        # with nvim-treesitter API changes in newer flake revisions.
        treesitter.context.enable = false;

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;
          cellular-automaton.enable = false;
        };

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
        };

        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = false;
        };

        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = false;
          };
        };
      };
    };
  };
}
