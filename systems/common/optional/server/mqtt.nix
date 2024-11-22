{ pkgs, ...}: {
  
  environment.systemPackages = with pkgs; [
#    node-red
    mosquitto
    zigbee2mqtt
  ];
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = true;
      serial = {
        port = "/dev/serial/by-id/usb-Nabu_Casa_Home_Assistant_Connect_ZBT-1_3ea952a99031ef1198c04dcfdfbc56eb-if00-port0";
      };
      mqtt = {
	server = "mqtt://localhost:1883";
	user = "matt";
	password = "#Yf/cI!GI|&EHXLR";
      };
    };
  };
  services.mosquitto = {
    enable = true;
    listeners = [
    {
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    }
  ];
};

networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 1883 ];
};
}
