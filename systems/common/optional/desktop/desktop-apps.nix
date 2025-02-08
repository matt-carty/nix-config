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
  google-chrome
  brave
  ];
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
  };
  
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}
