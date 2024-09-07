{ pkgs, ...}: {
  
  imports = [
    
    ./locale.nix
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    gh
  ];

}
