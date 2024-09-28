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
	desc = "Find file in project";
      }
      {
        action = "<cmd>Telescope live_grep<CR>";
	key = "<leader>fw";
	desc = "Find word in project";
      }
    ];
  };
}
