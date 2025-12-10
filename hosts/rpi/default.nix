{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./hardware.nix
  ];

  nix.settings = {
    trusted-users = [ "rpi" ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  hardware = {
    deviceTree.enable = true;
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
    graphics.enable = true;
  };

  console.enable = false;

  networking = {
    hostName = "rpi";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
    };
    nat = {
      enable = true;
      externalInterface = "end0";
      internalInterfaces = [ "wg0" ];
    };
    wg-quick.interfaces = {
      wg0 = {
        address = [ "10.200.200.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/home/wg0_privatekey";
        postUp = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.200.200.1/24 -o end0 -j MASQUERADE
        '';
        preDown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.200.200.1/24 -o end0 -j MASQUERADE
        '';
        peers = [
          {
            publicKey = "yz7sOEPeYVzdnpVhB99POm8JuWnh6D3gJvOMEqJwBEg=";
            allowedIPs = [ "10.200.200.2/32" ];
          }
        ];
      };
    };
  };

  services.hardware.argonone.enable = true;

  time.timeZone = "Asia/Jerusalem";

  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;

  users.users.dreinat_vpn = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyoFQ3loc2m2CHPv8ygnSxnWiWEISFGk6p3ipOcEN2i"
    ];
  };
  home-manager.users.dreinat_vpn = import ./users/dreinat_vpn.nix;

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  profiles = {
    dev.enable = true;
    ssh = {
      enable = true;
      ports = [ 26522 ];
    };
    system.enable = true;
  };
}
