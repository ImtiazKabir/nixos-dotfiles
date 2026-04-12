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
  };
  
  home.packages = with pkgs; [
    vim
    xclip
    qutebrowser
    tmux
    
    nerd-fonts.jetbrains-mono
  ];

  home.file.".config/tmux/".source = ./config/tmux/;


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

