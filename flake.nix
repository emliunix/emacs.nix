{
  description = "My Emacs Nix flake setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.05";
    nix-mode.url = "github:NixOS/nix-mode";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, nix-mode, flake-utils, emacs-overlay }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlay ];
      };
      myConfigPkg = import ./buildConfig.nix { trivialBuild = pkgs.emacsPackages.trivialBuild; };
      my-nix-mode = nix-mode.defaultPackage.${system};
      emacs = pkgs.emacsPgtkGcc.pkgs.withPackages (epkgs: (with epkgs.melpaStablePackages; [
        myConfigPkg
        company
        paredit
        emmet-mode
        rainbow-delimiters
        markdown-mode
        lsp-mode
        lsp-ui
        lsp-treemacs
        rust-mode
        yaml-mode
        syntax-subword
        my-nix-mode
        nixpkgs-fmt
        helm
        yasnippet
        magit
        zenburn-theme
      ]));
    in {
      defaultPackage = emacs;
      devShell = pkgs.mkShell {
        buildInputs = [
          emacs
        ];
      };
    });
}
