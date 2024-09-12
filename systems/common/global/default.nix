{ pkgs, ...}: {
  
  imports = [
    
    ./locale.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    libgccjit # for neovim lazyvim
    gccStdenv # troubleshooting lazyvim treesitter
    fd        # for lazyvim 
    ripgrep   # for lazyvim
    zoxide
    gh
  ];

}
