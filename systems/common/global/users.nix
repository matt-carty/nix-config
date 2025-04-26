{ 
  ...
  }: { 


  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # matt user is on all systems
    matt = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      uid =  1000;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBteXQnAI6CZavJTsr/MgDMlIH5gJtAtJXySvaDAc00n matt@razorback"
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFf41ijLtS97CqgCgjyMgsNhZTZG/bgsmD29Sk9NbxRP matt@docky"
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrDvClKLRmbUPgG1TnBs11udMQr8HmAUTsix44nj2ZwSOZG9NPPFxqRU4AN4mgITecN948B6Nmc2ygpofuXd+ZaLdMeBjduMgA+ZzdUeALhKmrBR4dtozjgdojOlA6rus3/aeCTBfGWUtPP5FmU2nCgmqMBl4XKUYy9yqTd7iAqcY/8QI6wvxBy29v7KWfc7nSncItzG5BI3bWm/s1ByknVMOTpUpc6uMsEHcZwuPHbtEepIrOkWDtS43U0RQk/EuQumx25GoVNHXScnNN5qsYWNqrbOjDGS4QPbC2MFTiZCdNlPPVJF2ZLxERi0EmyWG1H3CM1f6Lq53jQs1hnw0Y0Mn3WEUzwYI00gc1T2r3tMex/zqTT5MIvZLi0a9g4643OOfKdgBPLfhvKnc9KA51KKwq16uPcJv7+9s9vJODZ/9NuefmqzD8oSDYqB7cXWRqVe1FIGhIB75neOq2RQJc/9FIxTgVGn0Isb/mEsSKJoLFZxqteJb1SHmNsNQXsYk= matt@drummer"
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMHojdNHWV1KYONJdSnhMUXMKOHpvU3fU8sbd69142ct matt@alien" 
	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxvKmVDcszbYT7/5PfXk/VFJaI59Gzl/mNpg2jxgkOl matt@ipad"


      ];
      # Need to work out if absent groups cause an error? Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "docker"];
    };
    tryano = {
      initialPassword = "changeme";
      isNormalUser = true;
      uid = 1004;
      extraGroups = ["wheel"];
    };
  };
}
