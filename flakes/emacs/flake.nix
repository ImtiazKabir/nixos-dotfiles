{
  description = "Fully isolated reproducible Emacs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    myEmacs = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
      # Completion
      epkgs.vertico
      epkgs.company

      # Evil (Vim)
      epkgs.evil
      epkgs.evil-collection
      epkgs.undo-fu

      # Git
      epkgs.magit

      # Checks
      epkgs.flycheck

      # UI
      epkgs.gruber-darker-theme
      epkgs.which-key

      # Environment
      epkgs.envrc
    ]);

    fontConf = pkgs.makeFontsConf {
      fontDirectories = [
        pkgs.nerd-fonts.martian-mono
      ];
    };

    earlyInitBase = ''
      ;; -*- lexical-binding: t; -*-
      (setq package-enable-at-startup nil)
    '';

    xdgSetup = ''
      ;; XDG-compliant paths for persistent state
      (let ((data-dir (expand-file-name "emacs/" (or (getenv "XDG_DATA_HOME") "~/.local/share")))
            (cache-dir (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache")))
            (state-dir (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state"))))
        (dolist (dir (list data-dir cache-dir state-dir))
          (unless (file-exists-p dir) (make-directory dir t)))
        (setq custom-file (expand-file-name "custom.el" data-dir))
        (setq recentf-save-file (expand-file-name "recentf" state-dir))
        (setq savehist-file (expand-file-name "savehist" state-dir))
        (setq bookmark-default-file (expand-file-name "bookmarks" data-dir))
        (let ((backup-dir (expand-file-name "backups/" cache-dir))
              (auto-save-dir (expand-file-name "auto-saves/" cache-dir)))
          (dolist (d (list backup-dir auto-save-dir)) (unless (file-exists-p d) (make-directory d t)))
          (setq backup-directory-alist `(("." . ,backup-dir)))
          (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))))
        (when (boundp 'native-comp-eln-load-path)
          (startup-redirect-eln-cache (expand-file-name "eln-cache/" cache-dir)))
        (add-hook 'after-init-hook (lambda ()
          (recentf-mode 1) (savehist-mode 1) (save-place-mode 1)
          (when (file-exists-p custom-file) (load custom-file)))))
    '';

    mkConfig = { variant }: pkgs.runCommand "emacs-config-${variant}" {} ''
      mkdir -p $out
      cp ${./config/init.el} $out/init.el
      cat > $out/early-init.el << 'EOF'
      ${earlyInitBase}
      ${if variant == "persistent" then xdgSetup else ""}
      EOF
    '';

    configPersistent = mkConfig { variant = "persistent"; };
    configEphemeral = mkConfig { variant = "ephemeral"; };

    mkEmacs = { config, name }: pkgs.symlinkJoin {
      inherit name;
      paths = [ myEmacs ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/emacs \
          --set FONTCONFIG_FILE ${fontConf} \
          --add-flags "--init-directory=${config}" \
          --add-flags "--no-site-file" \
          --add-flags "--no-site-lisp"
      '';
    };

    persistent = mkEmacs { config = configPersistent; name = "emacs"; };

    ephemeral = pkgs.writeShellApplication {
      name = "emacs";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        HOME=$(mktemp -d)
        trap 'rm -rf "$HOME"' EXIT
        exec ${mkEmacs { config = configEphemeral; name = "emacs-ephemeral"; }}/bin/emacs "$@"
      '';
    };

  in {
    packages.${system} = {
      default = persistent;
      inherit persistent ephemeral;
    };

    apps.${system} = {
      default = { type = "app"; program = "${ephemeral}/bin/emacs"; };
      ephemeral = { type = "app"; program = "${ephemeral}/bin/emacs"; };
      persistent = { type = "app"; program = "${persistent}/bin/emacs"; };
    };
  };
}
