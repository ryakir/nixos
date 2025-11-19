{
  lib,
  config,
  ...
}:
let
  cfg = config.profiles.shell;
in
{
  imports = [
    ./starship/home.nix
    ./zsh/home.nix
  ];

  options.profiles.shell = {
    enable = lib.mkEnableOption "shell profile";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      bat.enable = true;
      fd.enable = true;
      ripgrep.enable = true;
      fzf =
        let
          fd = lib.getExe config.programs.fd.package;
        in
        {
          enable = true;
          defaultCommand = fd;
          fileWidgetCommand = "${fd} --type f";
          changeDirWidgetCommand = "${fd} --type d";
        };
      eza = {
        enable = true;
        git = true;
        icons = "auto";
      };

      bash = {
        enable = true;
        historyFile = "${config.xdg.stateHome}/.bash_history";
      };
    };

    profiles.shell = {
      zsh.enable = true;
    };
  };
}
