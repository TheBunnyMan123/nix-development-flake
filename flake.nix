{
  description = "A dev environment for nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, flake-utils, nix-vscode-extensions }: 
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          bashInteractive
          nixpkgs-fmt
          nixd
          (vscode-with-extensions.override {
            vscode = vscodium;

            vscodeExtensions = with nix-vscode-extensions.extensions.${system}.vscode-marketplace; [
              pkgs.vscode-extensions.jnoortheen.nix-ide
              mhutchie.git-graph
              aaron-bond.better-comments
            ];
          })
        ];

        shellHook = ''
          if [ ! -f .vscode/settings.json ]
          then
            echo '{"nix.serverPath":"nixd","nix.serverSettings":{"nixd":{"formatting":{"command":["nixpkgs-fmt"]},"options":{"nixos":{"expr":"(builtins.getFlake \"/absolute/path/to/flake\").nixosConfigurations.<name>.options"}}}},"nix.enableLanguageServer":true}' > .vscode/settings.json
          fi
          exec codium --verbose .
        '';
      };
    }
  );
}
