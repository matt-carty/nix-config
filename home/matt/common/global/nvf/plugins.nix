{lib, pkgs, ...}: {
  programs.nvf.settings.vim = {
    # Load after snacks so the picker source handler registers correctly.
    extraPlugins.todo-comments-nvim = {
      package = pkgs.vimPlugins.todo-comments-nvim;
      after = ["snacks-nvim"];
      setup = "require('todo-comments').setup({})";
    };

    # --- LazyVim plugin stack ---
    telescope.enable = lib.mkForce false;

    filetree.neo-tree.enable = false;

    utility = {
      snacks-nvim = {
        enable = true;
        setupOpts = {
          bigfile.enabled = true;
          dashboard.enabled = false;
          explorer = {};
          indent.enabled = true;
          input.enabled = true;
          notifier.enabled = true;
          picker.enabled = true;
          quickfile.enabled = true;
          scope.enabled = true;
          scroll.enabled = true;
          statuscolumn.enabled = true;
          words.enabled = true;
          lazygit = {};
        };
      };

      motion = {
        hop.enable = false;
        leap.enable = false;
        precognition.enable = false;
        flash-nvim.enable = true;
      };

      grug-far-nvim.enable = true;
      yanky-nvim = {
        enable = true;
        setupOpts.ring.storage = "memory";
      };
      smart-splits.enable = true;
      surround.enable = false;
      diffview-nvim.enable = true;
      icon-picker.enable = true;
      leetcode-nvim.enable = false;
      multicursors.enable = true;
      ccc.enable = false;
      vim-wakatime.enable = false;
      images.image-nvim.enable = false;
      images.img-clip.enable = false;
    };

    mini.surround = {
      enable = true;
      setupOpts.mappings = {
        add = "gsa";
        delete = "gsd";
        find = "gsf";
        find_left = "gsF";
        highlight = "gsh";
        replace = "gsr";
        update_n_lines = "gsn";
      };
    };

    formatter.conform-nvim.enable = true;

    ui.noice.enable = true;

    notify.nvim-notify.enable = false;

    visuals.cinnamon-nvim.enable = false;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
      hardtime-nvim.enable = false;
    };

    # --- Mapping overrides (null nvf defaults; LazyVim binds in keymaps.nix) ---
    lsp.mappings = {
      goToDefinition = null;
      goToDeclaration = null;
      goToType = null;
      listImplementations = null;
      listReferences = null;
      nextDiagnostic = null;
      previousDiagnostic = null;
      openDiagnosticFloat = null;
      documentHighlight = null;
      listDocumentSymbols = null;
      addWorkspaceFolder = null;
      removeWorkspaceFolder = null;
      listWorkspaceFolders = null;
      listWorkspaceSymbols = null;
      hover = null;
      signatureHelp = null;
      renameSymbol = null;
      codeAction = null;
      format = null;
      toggleFormatOnSave = null;
    };

    lsp.trouble.mappings = {
      workspaceDiagnostics = "<leader>xx";
      documentDiagnostics = "<leader>xX";
      locList = "<leader>xL";
      quickfix = "<leader>xQ";
      symbols = "<leader>cs";
      lspReferences = "<leader>cS";
    };

    tabline.nvimBufferline.mappings = {
      cycleNext = "]b";
      cyclePrevious = "[b";
      pick = "<leader>bj";
      closeCurrent = null;
      moveNext = "]B";
      movePrevious = "[B";
    };

    terminal.toggleterm = {
      mappings.open = null;
      lazygit.mappings.open = null;
    };

    utility.motion.flash-nvim.mappings = {
      jump = "s";
      treesitter = "S";
      remote = "r";
      treesitter_search = "R";
      toggle = "<c-s>";
    };

    utility.smart-splits = {
      keymaps = {
        move_cursor_left = "<C-h>";
        move_cursor_down = "<C-j>";
        move_cursor_up = "<C-k>";
        move_cursor_right = "<C-l>";
        resize_left = "<A-h>";
        resize_down = "<A-j>";
        resize_up = "<A-k>";
        resize_right = "<A-l>";
      };
    };

    git.gitsigns.mappings = {
      nextHunk = "]c";
      previousHunk = "[c";
      stageHunk = null;
      undoStageHunk = null;
      resetHunk = null;
      stageBuffer = null;
      resetBuffer = null;
      previewHunk = null;
      blameLine = null;
      toggleBlame = null;
      diffThis = null;
      diffProject = null;
      toggleDeleted = null;
    };
  };
}
