{
  description = "A Nix-based development environment and package for noxdir.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Systems supported by the flake
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # A helper function to apply a function to all supported systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              golangci-lint
            ];
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          noxdir = pkgs.buildGoModule {
            pname = "noxdir";
            version = "0.1.0"; # Replace with your project's version
            src = ./.;

            # This is the hash of the go.sum file's content.
            # You can get the correct hash by running `nix build` and letting it fail.
            vendorSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # <-- REPLACE THIS

            # Add the -s and -w flags to the build flags as specified in your Makefile.
            ldflags = [
              "-s"
              "-w"
            ];

            # The main package, which is the directory with the main.go file.
            # Usually this is "." for a simple project.
            subPackages = [ "." ];
          };

          default = self.packages.${system}.noxdir;
        }
      );
    };
}
