{config, pkgs, ... }:

{

  imports = [
    ../modules/suckless.nix
  ];

  home.stateVersion = "25.11";

  home.username = "sol";
  home.homeDirectory = "/home/sol";
  programs.home-manager.enable = true;

  xsession = {
    enable = true;
    windowManager.command = "${pkgs.dwm}/bin/dwm";
    initExtra = ''
      ${pkgs.slstatus}/bin/slstatus &
    '';
  };
  
  home.packages = with pkgs; [
    vim
    emacs
    xclip
    qutebrowser
    tmux
    tree
    nerd-fonts.jetbrains-mono
    nerd-fonts.martian-mono
    noto-fonts
    sioyek
    mpv
    ffmpeg
  ];

  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };


  # Fcitx5 with OpenBangla Keyboard
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-openbangla-keyboard
    ];
  };

  # Fcitx5 config: Ctrl+Alt+Space to toggle, English (US) + OpenBangla
  xdg.configFile."fcitx5/config" = {
    source = ../config/fcitx5/config;
    force = true;
  };
  xdg.configFile."fcitx5/profile" = {
    source = ../config/fcitx5/profile;
    force = true;
  };

  home.file.".config/qutebrowser/config.py".source = ../config/qutebrowser/config.py;

  home.file.".emacs.d/init.el".source = ../config/emacs/init.el;

  # home.file.".config/tmux.conf".source = ../config/tmux/tmux.conf;
  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1
      setw -g mode-keys vi
    '';
  };


  programs.git = {
    enable = true;
    settings.user.name = "ImtiazKabir";
    settings.user.email = "imtiazkabir.imtiaz@gmail.com";
    settings.init.defaultBranch = "main";
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  
    matchBlocks = {
      # This applies the agent setting to all hosts
      "*" = {
        addKeysToAgent = "yes";
      };
  
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}

