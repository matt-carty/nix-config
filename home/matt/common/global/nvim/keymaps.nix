{...}:
{
  programs.nixvim = {

    keymaps = [
    
      # Personal keymaps (initially taken from LazyVim)
      
      {
	key = "<C-h>";
	action = "<C-w>h";
	mode = "n";
	options = {
	  remap = true;
	  desc = "Move to left window";
	};
      }
      {
	key = "<C-j>";
	action = "<C-w>j";
	mode = "n";
	options = {
	  remap = true;
	  desc = "Move to lower window";
	};
      }
      {
	key = "<C-k>";
	action = "<C-w>k";
	mode = [
		"n"
		"t"
		];
	options = {
	  remap = true;
	  desc = "Move to upper window";
	};
      }
      {
	key = "<C-l>";
	action = "<C-w>l";
	mode = "n";
	options = {
	  remap = true;
	  desc = "Move to right window";
	};
      }
      {
	key = "<leader>bb";
	action = "<cmd>e #<cr>";
	mode = "n";
	options = {
	  desc = "Move to next buffer";
	};
      }
      {
	key = "<leader>hc";
	action = "<cmd>noh <cr>";
	mode = "n";
	options = {
	  desc = "Clear search highlight";
	};
      }
      # Neo-tree maps 
      {
        action = "<cmd>Neotree toggle<CR>";
        key = "<leader>e";
      }
      # Telescope maps 
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
