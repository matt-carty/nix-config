{ pkgs, services, ...}: {
# Enable CUPS and wifi compatible printers
  services.printing.enable = true;

  services.avahi = {
  enable = true;
  nssmdns = true;
  openFirewall = true;
  };

}
