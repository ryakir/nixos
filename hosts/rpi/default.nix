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
    ssh.enable = true;
    system.enable = true;
  };
}
