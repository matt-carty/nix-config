{ pkgs, ... }: {
  services.printing = {
    enable = true;
    cups-pdf.enable = true;
    # cups-browsed's implicit-class queues re-resolve destinations via mDNS at
    # print time and stall when a browse packet is missed. Use permanent
    # driverless-IPP queues declared below instead.
    browsed.enable = false;
  };

  hardware.printers = {
    ensureDefaultPrinter = "brother";
    ensurePrinters = [
      {
        name = "brother";
        location = "home";
        deviceUri = "ipp://brother.skippy.crty.io/ipp/print";
        model = "everywhere";
      }
      {
        # Canon's firmware rejects IPP with any Host header other than the
        # printer's IP or its own mDNS name — pin the URI to the DHCP-reserved
        # IP so driverless setup and prints go through.
        name = "canon";
        location = "home";
        deviceUri = "ipp://10.89.24.77/ipp/print";
        model = "everywhere";
      }
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = false;
    openFirewall = true;
    ipv4 = true;
    ipv6 = false;
    browseDomains = [ "skippy.crty.io" "home.crty.io" ];
    # Keep mDNS off docker/podman bridges; only advertise/listen on the LAN.
    allowInterfaces = [ "br0" ];
  };
}
