{ ...}: {

boot.kernelParams = [ "ip=dhcp" ];
boot.initrd = {
  availableKernelModules = [ "r8169" ];
  network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      authorizedKeys = [ "ssh-rsa AAAAyourpublic-key-here..." ];
      hostKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxvKmVDcszbYT7/5PfXk/VFJaI59Gzl/mNpg2jxgkOl" ];
      shell = "/bin/cryptsetup-askpass";
    };
  };
};
}
