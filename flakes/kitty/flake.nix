{
  description = "Fully isolated reproducible Kitty Terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # Bundle the required Martian Mono Nerd Font
    fontConf = pkgs.makeFontsConf {
      fontDirectories = [
        pkgs.nerd-fonts.martian-mono
      ];
    };

    # Persistent wrapper: Point directly to the configuration directory
    persistent = pkgs.symlinkJoin {
      name = "kitty";
      paths = [ pkgs.kitty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitty \
          --set FONTCONFIG_FILE ${fontConf} \
          --add-flags "--config ${./config/kitty.conf}"
      '';
    };

    # Ephemeral wrapper: Complete system isolation via synthetic context
    ephemeral = pkgs.writeShellApplication {
      name = "kitty";
      runtimeInputs = [ pkgs.coreutils pkgs.kitty ];
      text = ''
        # Generate clean, sandbox environments for State/Home data
        FAKE_HOME=$(mktemp -d)
        trap 'rm -rf "$FAKE_HOME"' EXIT

        # Run Kitty completely unlinked from host configurations.
        # --config NONE ignores standard system/user configurations
        # --override breaks down state inheritance by pointing paths to the sandbox
        HOME="$FAKE_HOME" \
        FONTCONFIG_FILE="${fontConf}" \
        exec "${pkgs.kitty}/bin/kitty" \
          --config NONE \
          --config "${./config/kitty.conf}" \
          --override "cache_dir=$FAKE_HOME/.cache/kitty" \
          "$@"
      '';
    };

  in {
    # Expose outputs for home-manager or packages
    packages.${system} = {
      default = persistent;
      inherit persistent ephemeral;
    };

    # Expose apps targets for direct 'nix run' actions
    apps.${system} = {
      default = { type = "app"; program = "${ephemeral}/bin/kitty"; };
      ephemeral = { type = "app"; program = "${ephemeral}/bin/kitty"; };
      persistent = { type = "app"; program = "${persistent}/bin/kitty"; };
    };
  };
}
