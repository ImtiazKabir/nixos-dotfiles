{
  description = "Fully isolated reproducible Kitty terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # Bundle the font so it is available regardless of what the host has installed
    fontConf = pkgs.makeFontsConf {
      fontDirectories = [
        pkgs.nerd-fonts.martian-mono
      ];
    };

    # The config directory baked into the store
    kittyConfig = pkgs.runCommand "kitty-config" {} ''
      mkdir -p $out
      cp ${./config/} $out/
    '';

    # ---------------------------------------------------------------------------
    # Persistent variant
    # Wraps kitty so it always uses the flake's config and bundled font.
    # Inherits the user's HOME and session normally — suitable for home-manager.
    # ---------------------------------------------------------------------------
    persistent = pkgs.symlinkJoin {
      name = "kitty";
      paths = [ pkgs.kitty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitty \
          --set   FONTCONFIG_FILE          "${fontConf}" \
          --set   KITTY_CONFIG_DIRECTORY   "${kittyConfig}" \
          --unset KITTY_LISTEN_ON \
          --unset KITTY_PID \
          --unset KITTY_WINDOW_ID \
          --unset KITTY_INSTALLATION_DIR
      '';
    };

    # ---------------------------------------------------------------------------
    # Ephemeral variant
    # Completely isolated: temporary HOME, no host kitty config, no inherited
    # socket / session / installation dir bleeds through.  All fonts and
    # packages come from the flake — no prerequisites on the host machine.
    # ---------------------------------------------------------------------------
    ephemeralInner = pkgs.symlinkJoin {
      name = "kitty-ephemeral-inner";
      paths = [ pkgs.kitty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitty \
          --set   FONTCONFIG_FILE          "${fontConf}" \
          --set   KITTY_CONFIG_DIRECTORY   "${kittyConfig}" \
          --unset KITTY_LISTEN_ON \
          --unset KITTY_PID \
          --unset KITTY_WINDOW_ID \
          --unset KITTY_INSTALLATION_DIR
      '';
    };

    ephemeral = pkgs.writeShellApplication {
      name = "kitty";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        # Spin up a throwaway HOME so kitty cannot read ~/.config/kitty,
        # ~/.local/share/kitty, or any other host-side state.
        ISOLATED_HOME=$(mktemp -d)
        trap 'rm -rf "$ISOLATED_HOME"' EXIT

        export HOME="$ISOLATED_HOME"
        export XDG_CONFIG_HOME="$ISOLATED_HOME/.config"
        export XDG_DATA_HOME="$ISOLATED_HOME/.local/share"
        export XDG_CACHE_HOME="$ISOLATED_HOME/.cache"
        export XDG_STATE_HOME="$ISOLATED_HOME/.local/state"
        export XDG_RUNTIME_DIR="$ISOLATED_HOME/run"

        # Hard-point kitty at the flake config; belt-and-suspenders alongside the wrapper
        export KITTY_CONFIG_DIRECTORY="${kittyConfig}"

        # Scrub every kitty session/socket variable so this instance cannot
        # attach to or be confused by any running kitty on the host.
        unset KITTY_LISTEN_ON
        unset KITTY_PID
        unset KITTY_WINDOW_ID
        unset KITTY_INSTALLATION_DIR

        exec ${ephemeralInner}/bin/kitty "$@"
      '';
    };

  in {
    packages.${system} = {
      default = persistent;
      inherit persistent ephemeral;
    };

    apps.${system} = {
      default  = { type = "app"; program = "${ephemeral}/bin/kitty"; };
      ephemeral  = { type = "app"; program = "${ephemeral}/bin/kitty"; };
      persistent = { type = "app"; program = "${persistent}/bin/kitty"; };
    };
  };
}
