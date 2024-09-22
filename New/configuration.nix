{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = true;
    };
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "yakirevich";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jerusalem";

  i18n.defaultLocale = "en_US.UTF-8";

  fileSystems."/mnt/yfsnfs" = {
    device = "10.0.0.100:/volume1/video";
    fsType = "nfs";
  };
  fileSystems."/mnt/media" = {
    device = "10.0.0.100:/volume1/media";
    fsType = "nfs";
  };

  virtualisation.docker.enable = true;

  users.users.roman = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  home-manager.users.roman = import ./user.nix;

  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [ "/share/zsh" ];
    systemPackages = with pkgs; [ wget ];
  };

  services = {
    openssh = {
      enable = true;
      # settings = {
      #   KbdInteractiveAuthentication = false;
      #   PasswordAuthentication = false;
      #   PermitRootLogin = "no";
      # };
    };
    tailscale.enable = true;
    vscode-server.enable = true;
    ddclient = {
      enable = true;
      ssl = true;
      usev4 = "web";
      protocol = "cloudflare";
      username = "roman@yakirevich.net";
      passwordFile = "/home/roman/nixos/ddclient-password.txt";
      zone = "yakirevich.dev";
      domains = [ "yakirevich.dev" ];
    };
    envfs.enable = true;
  };

  programs = {
    zsh.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    vim.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd
        libGL
        glib
      ];
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
