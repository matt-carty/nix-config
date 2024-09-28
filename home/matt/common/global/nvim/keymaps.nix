{...}:
{
  programs.nixvim = {

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
	options = {
	  desc = "Find file in project";
	};
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
	key = "<leader>fw";
	options = {
	  desc = "Grep find";
	};
      }
    ];
  };
}
