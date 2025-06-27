{...}: {
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
            setupOpts = ''
                                                                    adapters = {
                my_openai = function()
                  return require("codecompanion.adapters").extend("openai_compatible", {
                    env = {
                      url = "http[s]://open_compatible_ai_url", -- optional: default value is ollama url http://127.0.0.1:11434
                      api_key = "OpenAI_API_KEY", -- optional: if your endpoint is authenticated
                      chat_url = "/v1/chat/completions", -- optional: default value, override if different
                      models_endpoint = "/v1/models", -- optional: attaches to the end of the URL to form the endpoint to retrieve models
                    },
                    schema = {
                      model = {
                        default = "deepseek-r1-671b",  -- define llm model to be used
                      },
                      temperature = {
                        order = 2,
                        mapping = "parameters",
                        type = "number",
                        optional = true,
                        default = 0.8,
                        desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                        validate = function(n)
                          return n >= 0 and n <= 2, "Must be between 0 and 2"
                        end,
                      },
                      max_completion_tokens = {
                        order = 3,
                        mapping = "parameters",
                        type = "integer",
                        optional = true,
                        default = nil,
                        desc = "An upper bound for the number of tokens that can be generated for a completion.",
                        validate = function(n)
                          return n > 0, "Must be greater than 0"
                        end,
                      },
                      stop = {
                        order = 4,
                        mapping = "parameters",
                        type = "string",
                        optional = true,
                        default = nil,
                        desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                        validate = function(s)
                          return s:len() > 0, "Cannot be an empty string"
                        end,
                      },
                      logit_bias = {
                        order = 5,
                        mapping = "parameters",
                        type = "map",
                        optional = true,
                        default = nil,
                        desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
                        subtype_key = {
                          type = "integer",
                        },
                        subtype = {
                          type = "integer",
                          validate = function(n)
                            return n >= -100 and n <= 100, "Must be between -100 and 100"
                          end,
                        },
                      },
                    },
                  })
                end,
              },
            '';
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
