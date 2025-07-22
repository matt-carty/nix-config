{lib, ...}: {
  imports = [
  ];

  # Customisations for matt@medina
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        lsp = {
          enable = true;
          formatOnSave = true;
          trouble.enable = true;
          lspkind.enable = true;
        };
        languages = {
          enableFormat = true;
          enableTreesitter = true;

          nix.enable = true;
          markdown.enable = true;
          ts.enable = true;
          lua.enable = true;
          tailwind.enable = true;
          html.enable = true;
          css.enable = true;
          sql.enable = true;
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
        filetree = {
          neo-tree = {
            enable = true;
          };
        };
        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline.enable = true;

          # Fun
          cellular-automaton.enable = false;
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          hardtime-nvim.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
        };

        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = true; # lighter, faster, and uses lua for configuration
        };

        dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = false;
          icon-picker.enable = true;
          surround.enable = true;
          leetcode-nvim.enable = true;
          multicursors.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
          images = {
            image-nvim.enable = false;
            img-clip.enable = true;
          };
        };
        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };
      };
    };
  };
}
