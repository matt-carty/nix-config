{ pkgs, ...}: {
  
  environment.systemPackages = with pkgs; [
  nextcloud-client
  firefox
  keepassxc
  alacritty
  libreoffice
  hunspell
  hunspellDicts.en-au
  kdePackages.kdeconnect-kde
  ];

}
