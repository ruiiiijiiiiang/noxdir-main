{
  description = "A Nix-based development environment and package for noxdir.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      noxdir-package = pkgs.stdenv.mkDerivation {
        pname = "noxdir";
        version = "0.1.0";
        src = ./.;

        buildPhase = ''
          go build -ldflags "-s -w" -o ${pname}
        '';

        installPhase = ''
          mkdir -p $out/bin
          mv ${pname} $out/bin/
        '';
      };
    in
    {
      packages.x86_64-linux.default = noxdir-package;
      devShells.x86_64-linux.default = pkgs.mkShell {
        # The buildInputs are the packages available in the shell.
        buildInputs = with pkgs; [
          go
          golangci-lint
        ];
      };
    };
}
