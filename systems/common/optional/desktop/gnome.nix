{ pkgs, ...}: {
  
  environment.systemPackages = with pkgs; [
   gnome-tweaks 

  ];

}
