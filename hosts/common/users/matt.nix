#Something needs to go in here to make it work as a module/include
{
  pkgs,
  config,
  lib,
  ...
}:{


# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    initialPassword = "correcthorsebatterystaple";
    description = "Matt";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  packages for only Matt on all systems could go here
    ];
  };
}
