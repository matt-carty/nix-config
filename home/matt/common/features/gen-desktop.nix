
{ pkgs, ...}: {

  home.packages = with pkgs; [
    
   calibre 
   remmina
   pdfslicer
  ];
programs.gnome-shell = {
  enable = true;
  extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
};
}
