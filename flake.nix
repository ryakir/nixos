{
  description = "";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      eachSystem = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = eachSystem (system: import nixpkgs { inherit system; });

      nixRegistry = {
        nix.registry = builtins.mapAttrs (_: input: { flake = input; }) inputs;
      };
      nixosModules = [
        nixRegistry
        ./modules
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = homeManagerModules;
            extraSpecialArgs = {
              inherit inputs;
            };
          };
        }
      ];
      homeManagerModules = [
        nixRegistry
        ./modules/home.nix
      ];
      mkSystem =
        system: entrypoint:
        nixpkgs.lib.nixosSystem {
          system = system;
          modules = nixosModules ++ [ entrypoint ];
          specialArgs = {
            inherit inputs;
          };
        };
    in
    rec {
      checks = eachSystem (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      devShells = eachSystem (
        system: with pkgsFor.${system}; {
          default = mkShell {
            inherit (checks.${system}.pre-commit-check) shellHook;
            buildInputs = checks.${system}.pre-commit-check.enabledPackages;
          };
        }
      );
      formatter = eachSystem (system: with pkgsFor.${system}; pkgs.nixfmt-rfc-style);

      nixosConfigurations = {
        rpi = mkSystem "aarch64-linux" ./hosts/rpi;
      };
    };
}
