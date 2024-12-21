{ pkgs, inputs, ...}: {
  
  imports = [
    
    ./locale.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    git
    zoxide # super awesome
    kanata # haven't set up yet TODO
    gh # for authenticating mainly 
    fzf
    nmap
    dig
    nixd # for nix lsp in nvim
    htop
    usbutils # useful utility TODO separate useful utilities into their own file
  ];
  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
