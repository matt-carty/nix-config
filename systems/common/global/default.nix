{ pkgs, ...}: {
  
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
    direnv
  ];

}
