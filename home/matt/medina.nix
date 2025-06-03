{
  ...
}: {
  imports = [
    ./common/global/default.nix
    ./common/features/editing.nix
    ./common/features/obsidian.nix
    ./common/features/gen-desktop.nix
  ]; 

  # Customisations for matt@medina
  programs.kitty = {
    settings = {
      font_size = 11;
    };
   };
  programs.nvf = {
    enable = true;
        settings = {
       
        vim = {

        lsp = { 
          enable = true;

          trouble.enable = true;
        };
       languages =  { 
       
         enableFormat = true;
         enableTreesitter = true;

         nix.enable = true; 
         markdown.enable = true;
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
        theme = "rose-pine";
      };
    };
                                filetree = {
      neo-tree = {
        enable = true;
      };
    };
        };
    };
};
}
