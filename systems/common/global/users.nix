{...}: {
  users.groups.media = {gid = 13000;};

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # matt user is on all systems
    matt = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      uid = 1000;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBteXQnAI6CZavJTsr/MgDMlIH5gJtAtJXySvaDAc00n matt@razorback"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFf41ijLtS97CqgCgjyMgsNhZTZG/bgsmD29Sk9NbxRP matt@docky"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrDvClKLRmbUPgG1TnBs11udMQr8HmAUTsix44nj2ZwSOZG9NPPFxqRU4AN4mgITecN948B6Nmc2ygpofuXd+ZaLdMeBjduMgA+ZzdUeALhKmrBR4dtozjgdojOlA6rus3/aeCTBfGWUtPP5FmU2nCgmqMBl4XKUYy9yqTd7iAqcY/8QI6wvxBy29v7KWfc7nSncItzG5BI3bWm/s1ByknVMOTpUpc6uMsEHcZwuPHbtEepIrOkWDtS43U0RQk/EuQumx25GoVNHXScnNN5qsYWNqrbOjDGS4QPbC2MFTiZCdNlPPVJF2ZLxERi0EmyWG1H3CM1f6Lq53jQs1hnw0Y0Mn3WEUzwYI00gc1T2r3tMex/zqTT5MIvZLi0a9g4643OOfKdgBPLfhvKnc9KA51KKwq16uPcJv7+9s9vJODZ/9NuefmqzD8oSDYqB7cXWRqVe1FIGhIB75neOq2RQJc/9FIxTgVGn0Isb/mEsSKJoLFZxqteJb1SHmNsNQXsYk= matt@drummer"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMHojdNHWV1KYONJdSnhMUXMKOHpvU3fU8sbd69142ct matt@alien"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxvKmVDcszbYT7/5PfXk/VFJaI59Gzl/mNpg2jxgkOl matt@ipad"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ1mNtM0aqZqCRFBjkpdROq1EQh+Ulr068vuK2hPjzel"
      ];
      # Need to work out if absent groups cause an error? Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "docker" "video" "render" "audio" "media" "backup"];
    };
    backup = {
      initialPassword = "calibrateoutbidgrimeprewar";
      isNormalUser = true;
      uid = 1007;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDbwv7Nd7QoWGyxZj9eX8SKxHa2VOUQ67PcHQElUFkfBvsZFGKLGj4mAjCw9j2W2D6d0jGxAyk84qgI0XVtCGsECWwpJOO34y/iI7sPKUP2elv+aBwsk/7kcz/PaZAjxLn0IhypLr8fEsiVB1P2qz73bW2230NLN3WSXx85efjUYmRiubsMJikOfNOVBD3XSylmLLXg0q002e02KC4auO9CTOTqjW4nNmdlMypooyPTXIGAWFkHjr5ospfmMoDNS2tADFhoR5yZkcN06mDL36tK+2/m+K/Txrs+0+Gd4GPqJy4LXCSJCf9xWGGmRIu5Na+42StqCJUmQzpWvKf78VUu7ZpHVV9Tq+h/Rrunqn+QVXyPAPa5Sym9SwFYDrU9pitru3F8ohD6YKsWeHNdbGLD122QZb08ARolsPVso7E0/9/JaEt82rku7Z88GsuyouENarwwt6OCEfj1w2dAqSsBjSxfWso4xfXvoATTrZ5/m6U/4iFDD9lsjVTZCUqhYAE= root@ceres"
      ];

      extraGroups = ["wheel" "backup"];
    };
  };
}
