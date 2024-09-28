{
  ...
}:
{
  programs.nixvim = {
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
        settings.sources = [
	  { name = "nvim_lsp"; }
	  { name = "path"; }
	  { name = "buffer"; }
	];

      };

    plugins.cmp-buffer.enable = true;
    plugins.cmp-nvim-lsp.enable = true;
    plugins.cmp-path.enable = true;
  };
}
