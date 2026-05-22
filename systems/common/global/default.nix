{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./locale.nix
    ./users.nix
    ./backup-nfs.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    git
    zoxide # super awesome
    #    kanata # move this to alien
    gh # for authenticating mainly
    fzf
    nmap
    dig
    nixd # for nix lsp in nvim
    htop
    usbutils # useful utility TODO separate useful utilities into their own file
    tmux
  ];

  # for nixd
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
