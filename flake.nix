{
  description = "My Emacs Nix flake setup";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    # nix-mode = { url = "github:NixOS/nix-mode"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, /* nix-mode, */ flake-utils, emacs-overlay }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlay ];
      };
      emacsPkgs = pkgs.emacsPgtkGcc.pkgs;
      myConfigPkg = import ./buildConfig.nix { trivialBuild = emacsPkgs.trivialBuild; };
      # my-nix-mode = nix-mode.defaultPackage.${system};
      emacs = emacsPkgs.withPackages (epkgs: (with epkgs.melpaStablePackages; [
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
        # my-nix-mode
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
