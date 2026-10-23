{...}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    availableKernelModules = ["r8169"];
    # systemd >=258 defaults DHCPv4 ClientIdentifier to a DUID instead of the
    # MAC, which the router's MAC-keyed static lease for this host doesn't
    # recognize, so it falls back to a random pool address on every boot.
    systemd.network.config.dhcpV4Config.ClientIdentifier = "mac";
    # Default job-start timeout (90s) is too tight for a remote LUKS unlock --
    # there can be a real gap between the initrd coming up and someone
    # actually SSHing in to type the passphrase. Past 90s, systemd was marking
    # the units waiting on the encrypted root as failed ("Dependency failed
    # for Initrd Root Device", etc.) even though cryptsetup itself has no
    # timeout and was still waiting at the prompt the whole time.
    systemd.settings.Manager.DefaultTimeoutStartSec = "5min";
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
