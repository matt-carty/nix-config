{ pkgs, ...}: {
  
  environment.systemPackages = with pkgs; [
  nextcloud-client
  firefox
  keepassxc
  alacritty
  kitty
  ];

}
