{ pkgs, inputs, ...}: {
  
  imports = [
    
    ./locale.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    zoxide
    kanata
    gh # need to see if I really need this...
    fzf
    nmap
    dig
    nixd
    htop
  ];
  # for nixd
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
