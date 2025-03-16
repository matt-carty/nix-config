{ pkgs, services, ...}: {
# Enable CUPS and wifi compatible printers
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;

  services.avahi = {
  enable = true;
  nssmdns4 = true;
  nssmdns6 = false;
  openFirewall = true;
  ipv4 = false;
  ipv6 = true;
  browseDomains = [ "skippy.crty.io" "home.crty.io" ];
  };

}
