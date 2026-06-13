{
  pkgs,
  ...
}: {
  imports = [
    ./nix-settings.nix
    ./locale.nix
    ./users.nix
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
}
