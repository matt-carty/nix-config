{...}: {
  programs.nvf.settings.vim.keymaps = [
    # --- General: movement ---
    {
      key = "j";
      mode = ["n" "x"];
      expr = true;
      silent = true;
      action = "v:count == 0 ? 'gj' : 'j'";
      desc = "Down";
    }
    {
      key = "<Down>";
      mode = ["n" "x"];
      expr = true;
      silent = true;
      action = "v:count == 0 ? 'gj' : 'j'";
      desc = "Down";
    }
    {
      key = "k";
      mode = ["n" "x"];
      expr = true;
      silent = true;
      action = "v:count == 0 ? 'gk' : 'k'";
      desc = "Up";
    }
    {
      key = "<Up>";
      mode = ["n" "x"];
      expr = true;
      silent = true;
      action = "v:count == 0 ? 'gk' : 'k'";
      desc = "Up";
    }

    # --- Buffers ---
    {
      key = "<S-h>";
      mode = "n";
      action = "<cmd>bprevious<cr>";
      desc = "Prev Buffer";
    }
    {
      key = "<S-l>";
      mode = "n";
      action = "<cmd>bnext<cr>";
      desc = "Next Buffer";
    }
    {
      key = "<leader>bb";
      mode = "n";
      action = "<cmd>e #<cr>";
      desc = "Switch to Other Buffer";
    }
    {
      key = "<leader><leader>";
      mode = "n";
      action = "<cmd>e #<cr>";
      desc = "Switch to Other Buffer";
    }
    {
      key = "<leader>bd";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").bufdelete() end'';
      desc = "Delete Buffer";
    }
    {
      key = "<leader>bo";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").bufdelete.other() end'';
      desc = "Delete Other Buffers";
    }
    {
      key = "<leader>bi";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").bufdelete.invisible() end'';
      desc = "Delete Invisible Buffers";
    }
    {
      key = "<leader>bD";
      mode = "n";
      action = "<cmd>bd<cr>";
      desc = "Delete Buffer and Window";
    }
    {
      key = "<leader>bl";
      mode = "n";
      action = "<cmd>BufferLineCloseLeft<cr>";
      desc = "Delete Buffers to the Left";
    }
    {
      key = "<leader>br";
      mode = "n";
      action = "<cmd>BufferLineCloseRight<cr>";
      desc = "Delete Buffers to the Right";
    }
    {
      key = "<leader>bp";
      mode = "n";
      action = "<cmd>BufferLineTogglePin<cr>";
      desc = "Toggle Pin";
    }
    {
      key = "<leader>bP";
      mode = "n";
      action = "<cmd>BufferLineDeleteNotPinned<cr>";
      desc = "Delete Non-Pinned Buffers";
    }

    # --- Windows ---
    {
      key = "<leader>-";
      mode = "n";
      noremap = false;
      action = "<cmd>split<cr>";
      desc = "Split Window Below";
    }
    {
      key = "<leader>|";
      mode = "n";
      noremap = false;
      action = "<cmd>vsplit<cr>";
      desc = "Split Window Right";
    }
    {
      key = "<leader>wd";
      mode = "n";
      noremap = false;
      action = "<C-w>c";
      desc = "Delete Window";
    }
    {
      key = "<leader>wm";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.zoom():toggle() end'';
      desc = "Toggle Zoom Mode";
    }
    {
      key = "<leader>uz";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.zen():toggle() end'';
      desc = "Toggle Zen Mode";
    }
    {
      key = "<leader>uZ";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.zoom():toggle() end'';
      desc = "Toggle Zoom Mode";
    }

    # --- Save / quit / search ---
    {
      key = "<C-s>";
      mode = ["n" "i" "x" "s"];
      noremap = false;
      action = "<cmd>w<cr>";
      desc = "Save File";
    }
    {
      key = "<leader>qq";
      mode = "n";
      action = "<cmd>qa<cr>";
      desc = "Quit All";
    }
    {
      key = "<leader>ur";
      mode = "n";
      action = "<cmd>nohlsearch<cr><cmd>diffupdate<cr><cmd>redraw!<cr>";
      desc = "Redraw / Clear hlsearch / Diff Update";
    }
    {
      key = "n";
      mode = ["n" "x" "o"];
      expr = true;
      silent = true;
      action = "'Nn'[v:searchforward].'zv'";
      desc = "Next Search Result";
    }
    {
      key = "N";
      mode = ["n" "x" "o"];
      expr = true;
      silent = true;
      action = "'nN'[v:searchforward].'zv'";
      desc = "Prev Search Result";
    }
    {
      key = "<leader>fn";
      mode = "n";
      action = "<cmd>enew<cr>";
      desc = "New File";
    }

    # --- Diagnostics ---
    {
      key = "<leader>cd";
      mode = "n";
      lua = true;
      action = "function() vim.diagnostic.open_float() end";
      desc = "Line Diagnostics";
    }
    {
      key = "]d";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = 1 * vim.v.count1, float = true }) end'';
      desc = "Next Diagnostic";
    }
    {
      key = "[d";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = -1 * vim.v.count1, float = true }) end'';
      desc = "Prev Diagnostic";
    }
    {
      key = "]e";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = 1 * vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end'';
      desc = "Next Error";
    }
    {
      key = "[e";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = -1 * vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end'';
      desc = "Prev Error";
    }
    {
      key = "]w";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = 1 * vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end'';
      desc = "Next Warning";
    }
    {
      key = "[w";
      mode = "n";
      lua = true;
      action = ''function() vim.diagnostic.jump({ count = -1 * vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end'';
      desc = "Prev Warning";
    }

    # --- Format ---
    {
      key = "<leader>cf";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("conform").format({ async = true, lsp_format = "fallback" }) end'';
      desc = "Format";
    }
    {
      key = "<leader>cF";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("conform").format({ async = true, lsp_format = "fallback" }) end'';
      desc = "Format Injected Langs";
    }

    # --- LSP ---
    {
      key = "gd";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_definitions() end'';
      desc = "Goto Definition";
    }
    {
      key = "gr";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_references() end'';
      desc = "References";
    }
    {
      key = "gI";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_implementations() end'';
      desc = "Goto Implementation";
    }
    {
      key = "gy";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_type_definitions() end'';
      desc = "Goto T[y]pe Definition";
    }
    {
      key = "gD";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.declaration()<cr>";
      desc = "Goto Declaration";
    }
    {
      key = "K";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      desc = "Hover";
    }
    {
      key = "gK";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.signature_help()<cr>";
      desc = "Signature Help";
    }
    {
      key = "<C-h>";
      mode = "i";
      action = "<cmd>lua vim.lsp.buf.signature_help()<cr>";
      desc = "Signature Help";
    }
    {
      key = "<leader>ca";
      mode = ["n" "x"];
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      desc = "Code Action";
    }
    {
      key = "<leader>cc";
      mode = ["n" "x"];
      action = "<cmd>lua vim.lsp.codelens.run()<cr>";
      desc = "Run Codelens";
    }
    {
      key = "<leader>cC";
      mode = "n";
      action = "<cmd>lua vim.lsp.codelens.refresh()<cr>";
      desc = "Refresh & Display Codelens";
    }
    {
      key = "<leader>cr";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      desc = "Rename";
    }
    {
      key = "<leader>co";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.code_action({ filter = { kind = 'source.organizeImports' }, apply = true })<cr>";
      desc = "Organize Imports";
    }
    {
      key = "<leader>cl";
      mode = "n";
      action = "<cmd>LspInfo<cr>";
      desc = "Lsp Info";
    }
    {
      key = "gai";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_incoming_calls() end'';
      desc = "C[a]lls Incoming";
    }
    {
      key = "gao";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_outgoing_calls() end'';
      desc = "C[a]lls Outgoing";
    }

    # --- Snacks: top-level picker ---
    {
      key = "<leader><space>";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.files() end'';
      desc = "Find Files (Root Dir)";
    }
    {
      key = "<leader>,";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.buffers() end'';
      desc = "Buffers";
    }
    {
      key = "<leader>/";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.grep() end'';
      desc = "Grep (Root Dir)";
    }
    {
      key = "<leader>:";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.command_history() end'';
      desc = "Command History";
    }
    {
      key = "<leader>n";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.notifications() end'';
      desc = "Notification History";
    }

    # --- Snacks: explorer ---
    {
      key = "<leader>e";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").explorer() end'';
      desc = "Explorer Snacks (root dir)";
    }
    {
      key = "<leader>E";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").explorer({ cwd = vim.fn.getcwd() }) end'';
      desc = "Explorer Snacks (cwd)";
    }
    {
      key = "<leader>fe";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").explorer() end'';
      desc = "Explorer Snacks (root dir)";
    }
    {
      key = "<leader>fE";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").explorer({ cwd = vim.fn.getcwd() }) end'';
      desc = "Explorer Snacks (cwd)";
    }

    # --- Snacks: find ---
    {
      key = "<leader>ff";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.files() end'';
      desc = "Find Files (Root Dir)";
    }
    {
      key = "<leader>fF";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.files({ cwd = vim.fn.getcwd() }) end'';
      desc = "Find Files (cwd)";
    }
    {
      key = "<leader>fg";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_files() end'';
      desc = "Find Files (git-files)";
    }
    {
      key = "<leader>fr";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.recent() end'';
      desc = "Recent";
    }
    {
      key = "<leader>fR";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.recent({ filter = { cwd = true } }) end'';
      desc = "Recent (cwd)";
    }
    {
      key = "<leader>fp";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.projects() end'';
      desc = "Projects";
    }
    {
      key = "<leader>fb";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.buffers() end'';
      desc = "Buffers";
    }
    {
      key = "<leader>fB";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.buffers({ hidden = true, nofile = true }) end'';
      desc = "Buffers (all)";
    }
    {
      key = "<leader>fc";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end'';
      desc = "Find Config File";
    }

    # --- Snacks: search ---
    {
      key = "<leader>sg";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.grep() end'';
      desc = "Grep (Root Dir)";
    }
    {
      key = "<leader>sG";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.grep({ cwd = vim.fn.getcwd() }) end'';
      desc = "Grep (cwd)";
    }
    {
      key = "<leader>ss";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_symbols() end'';
      desc = "LSP Symbols";
    }
    {
      key = "<leader>sS";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lsp_workspace_symbols() end'';
      desc = "LSP Workspace Symbols";
    }
    {
      key = "<leader>sb";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.lines() end'';
      desc = "Buffer Lines";
    }
    {
      key = "<leader>sB";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.grep_buffers() end'';
      desc = "Grep Open Buffers";
    }
    {
      key = "<leader>sd";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.diagnostics() end'';
      desc = "Diagnostics";
    }
    {
      key = "<leader>sD";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.diagnostics_buffer() end'';
      desc = "Buffer Diagnostics";
    }
    {
      key = "<leader>sh";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.help() end'';
      desc = "Help Pages";
    }
    {
      key = "<leader>sH";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.highlights() end'';
      desc = "Highlights";
    }
    {
      key = "<leader>si";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.icons() end'';
      desc = "Icons";
    }
    {
      key = "<leader>sj";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.jumps() end'';
      desc = "Jumps";
    }
    {
      key = "<leader>sk";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.keymaps() end'';
      desc = "Keymaps";
    }
    {
      key = "<leader>sl";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.loclist() end'';
      desc = "Location List";
    }
    {
      key = "<leader>sm";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.marks() end'';
      desc = "Marks";
    }
    {
      key = "<leader>sM";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.man() end'';
      desc = "Man Pages";
    }
    {
      key = "<leader>sq";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.qflist() end'';
      desc = "Quickfix List";
    }
    {
      key = "<leader>sR";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.resume() end'';
      desc = "Resume";
    }
    {
      key = "<leader>su";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.undo() end'';
      desc = "Undotree";
    }
    {
      key = "<leader>sa";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.autocmds() end'';
      desc = "Autocmds";
    }
    {
      key = "<leader>sc";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.command_history() end'';
      desc = "Command History";
    }
    {
      key = "<leader>sC";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.commands() end'';
      desc = "Commands";
    }
    {
      key = "<leader>s/";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.search_history() end'';
      desc = "Search History";
    }
    {
      key = "<leader>s\"";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.registers() end'';
      desc = "Registers";
    }
    {
      key = "<leader>sw";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("snacks").picker.grep_word() end'';
      desc = "Visual selection or word (Root Dir)";
    }
    {
      key = "<leader>sW";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("snacks").picker.grep_word({ cwd = vim.fn.getcwd() }) end'';
      desc = "Visual selection or word (cwd)";
    }
    {
      key = "]t";
      mode = "n";
      action = "<cmd>lua require('todo-comments').jump_next()<CR>";
      desc = "Next Todo Comment";
    }
    {
      key = "[t";
      mode = "n";
      action = "<cmd>lua require('todo-comments').jump_prev()<CR>";
      desc = "Previous Todo Comment";
    }
    {
      key = "<leader>st";
      mode = "n";
      lua = true;
      action = ''
        function()
          require("todo-comments")
          Snacks.picker.todo_comments()
        end
      '';
      desc = "Todo";
    }
    {
      key = "<leader>sT";
      mode = "n";
      lua = true;
      action = ''
        function()
          require("todo-comments")
          Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
        end
      '';
      desc = "Todo/Fix/Fixme";
    }

    # --- Git (snacks) ---
    {
      key = "<leader>gs";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_status() end'';
      desc = "Git Status";
    }
    {
      key = "<leader>gS";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_stash() end'';
      desc = "Git Stash";
    }
    {
      key = "<leader>gd";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_diff() end'';
      desc = "Git Diff (hunks)";
    }
    {
      key = "<leader>gD";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_diff({ base = "origin", group = true }) end'';
      desc = "Git Diff (origin)";
    }
    {
      key = "<leader>gl";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_log() end'';
      desc = "Git Log";
    }
    {
      key = "<leader>gL";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_log() end'';
      desc = "Git Log (cwd)";
    }
    {
      key = "<leader>gb";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_log_line() end'';
      desc = "Git Blame Line";
    }
    {
      key = "<leader>gf";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.git_log_file() end'';
      desc = "Git Current File History";
    }
    {
      key = "<leader>gi";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.gh_issue() end'';
      desc = "GitHub Issues (open)";
    }
    {
      key = "<leader>gI";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.gh_issue({ state = "all" }) end'';
      desc = "GitHub Issues (all)";
    }
    {
      key = "<leader>gp";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.gh_pr() end'';
      desc = "GitHub Pull Requests (open)";
    }
    {
      key = "<leader>gP";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.gh_pr({ state = "all" }) end'';
      desc = "GitHub Pull Requests (all)";
    }
    {
      key = "<leader>gB";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("snacks").gitbrowse() end'';
      desc = "Git Browse (open)";
    }
    {
      key = "<leader>gY";
      mode = ["n" "x"];
      lua = true;
      action = ''
        function()
          require("snacks").gitbrowse({
            open = function(url) vim.fn.setreg("+", url) end,
            notify = false,
          })
        end
      '';
      desc = "Git Browse (copy)";
    }
    {
      key = "<leader>gg";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").lazygit() end'';
      desc = "Lazygit (cwd)";
    }
    {
      key = "<leader>gG";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").lazygit({ cwd = vim.fn.getcwd() }) end'';
      desc = "Lazygit (cwd)";
    }

    # --- Terminal ---
    {
      key = "<C-\\>";
      mode = ["n" "t"];
      lua = true;
      action = ''function() require("snacks").terminal.focus() end'';
      desc = "Terminal (Root Dir)";
    }
    {
      key = "<leader>ft";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").terminal() end'';
      desc = "Terminal (Root Dir)";
    }
    {
      key = "<leader>fT";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").terminal(nil, { cwd = vim.fn.getcwd() }) end'';
      desc = "Terminal (cwd)";
    }

    # --- Toggles (snacks) ---
    {
      key = "<leader>uf";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.format():toggle() end'';
      desc = "Toggle Auto Format (Global)";
    }
    {
      key = "<leader>uF";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.format({ buf = true }):toggle() end'';
      desc = "Toggle Auto Format (Buffer)";
    }
    {
      key = "<leader>us";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("spell"):toggle() end'';
      desc = "Toggle Spelling";
    }
    {
      key = "<leader>uw";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("wrap"):toggle() end'';
      desc = "Toggle Wrap";
    }
    {
      key = "<leader>uL";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("relativenumber"):toggle() end'';
      desc = "Toggle Relative Number";
    }
    {
      key = "<leader>ud";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.diagnostics():toggle() end'';
      desc = "Toggle Diagnostics";
    }
    {
      key = "<leader>ul";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.line_number():toggle() end'';
      desc = "Toggle Line Numbers";
    }
    {
      key = "<leader>uc";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):toggle() end'';
      desc = "Toggle Conceal Level";
    }
    {
      key = "<leader>uA";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2 }):toggle() end'';
      desc = "Toggle Tabline";
    }
    {
      key = "<leader>uT";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.treesitter():toggle() end'';
      desc = "Toggle Treesitter Highlight";
    }
    {
      key = "<leader>ub";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.option("background", { off = "light", on = "dark" }):toggle() end'';
      desc = "Toggle Dark Background";
    }
    {
      key = "<leader>uD";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.dim():toggle() end'';
      desc = "Toggle Dimming";
    }
    {
      key = "<leader>ua";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.animate():toggle() end'';
      desc = "Toggle Animations";
    }
    {
      key = "<leader>ug";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.indent():toggle() end'';
      desc = "Toggle Indent Guides";
    }
    {
      key = "<leader>uS";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.scroll():toggle() end'';
      desc = "Toggle Smooth Scroll";
    }
    {
      key = "<leader>uh";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").toggle.inlay_hints():toggle() end'';
      desc = "Toggle Inlay Hints";
    }
    {
      key = "<leader>uC";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").picker.colorschemes() end'';
      desc = "Colorschemes";
    }
    {
      key = "<leader>un";
      mode = "n";
      lua = true;
      action = ''function() require("snacks").notifier.hide() end'';
      desc = "Dismiss All Notifications";
    }
    {
      key = "<leader>ui";
      mode = "n";
      lua = true;
      action = "function() vim.show_pos() end";
      desc = "Inspect Pos";
    }
    {
      key = "<leader>uI";
      mode = "n";
      lua = true;
      action = ''
        function()
          vim.treesitter.inspect_tree()
          vim.api.nvim_input("I")
        end
      '';
      desc = "Inspect Tree";
    }

    # --- Lists / quickfix ---
    {
      key = "<leader>xl";
      mode = "n";
      lua = true;
      action = ''
        function()
          if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
            vim.cmd.lclose()
          else
            vim.cmd.lopen()
          end
        end
      '';
      desc = "Location List";
    }
    {
      key = "<leader>xq";
      mode = "n";
      lua = true;
      action = ''
        function()
          if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
            vim.cmd.cclose()
          else
            vim.cmd.copen()
          end
        end
      '';
      desc = "Quickfix List";
    }
    {
      key = "[q";
      mode = "n";
      action = "<cmd>cprev<cr>";
      desc = "Previous Quickfix";
    }
    {
      key = "]q";
      mode = "n";
      action = "<cmd>cnext<cr>";
      desc = "Next Quickfix";
    }

    # --- grug-far ---
    {
      key = "<leader>sr";
      mode = ["n" "x"];
      lua = true;
      action = ''function() require("grug-far").open() end'';
      desc = "Search and Replace";
    }

    # --- Tabs ---
    {
      key = "<leader><tab>l";
      mode = "n";
      action = "<cmd>tablast<cr>";
      desc = "Last Tab";
    }
    {
      key = "<leader><tab>o";
      mode = "n";
      action = "<cmd>tabonly<cr>";
      desc = "Close Other Tabs";
    }
    {
      key = "<leader><tab>f";
      mode = "n";
      action = "<cmd>tabfirst<cr>";
      desc = "First Tab";
    }
    {
      key = "<leader><tab><tab>";
      mode = "n";
      action = "<cmd>tabnew<cr>";
      desc = "New Tab";
    }
    {
      key = "<leader><tab>]";
      mode = "n";
      action = "<cmd>tabnext<cr>";
      desc = "Next Tab";
    }
    {
      key = "<leader><tab>d";
      mode = "n";
      action = "<cmd>tabclose<cr>";
      desc = "Close Tab";
    }
    {
      key = "<leader><tab>[";
      mode = "n";
      action = "<cmd>tabprevious<cr>";
      desc = "Previous Tab";
    }
  ];
}
