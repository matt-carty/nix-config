
{ pkgs, ...}: {

  home.packages = with pkgs; [
    
   calibre 
   remmina
  ];
programs.gnome-shell = {
  enable = true;
  extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
};
}
