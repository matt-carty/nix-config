{ pkgs, inputs, ...}: {
  
  imports = [
    
    ./locale.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    git
    zoxide
    kanata
    gh # need to see if I really need this...don't if I use ssh for git
    fzf
    nmap
    dig
    nixd
    htop
  ];
  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
