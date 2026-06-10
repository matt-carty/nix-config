{pkgs, ...}: {
  programs.nvf.settings.vim.lazy.plugins = {
    "persistence.nvim" = {
      package = pkgs.vimPlugins.persistence-nvim;
      setupModule = "persistence";
      keys = [
        {
          key = "<leader>qd";
          mode = "n";
          action = "<cmd>lua require('persistence').stop()<CR>";
        }
        {
          key = "<leader>ql";
          mode = "n";
          action = "<cmd>lua require('persistence').load({ last = true })<CR>";
        }
        {
          key = "<leader>qs";
          mode = "n";
          action = "<cmd>lua require('persistence').load()<CR>";
        }
        {
          key = "<leader>qS";
          mode = "n";
          action = "<cmd>lua require('persistence').select()<CR>";
        }
      ];
    };
  };
}
