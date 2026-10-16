{...}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    availableKernelModules = ["r8169"];
    # systemd >=258 defaults DHCPv4 ClientIdentifier to a DUID instead of the
    # MAC, which the router's MAC-keyed static lease for this host doesn't
    # recognize, so it falls back to a random pool address on every boot.
    systemd.network.config.dhcpV4Config.ClientIdentifier = "mac";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          "command=\"systemctl default\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxvKmVDcszbYT7/5PfXk/VFJaI59Gzl/mNpg2jxgkOl matt@ipad"
          "command=\"systemctl default\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1mNtM0aqZqCRFBjkpdROq1EQh+Ulr068vuK2hPjzel matt@medina"
        ];
        hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
      };
    };
  };
}
