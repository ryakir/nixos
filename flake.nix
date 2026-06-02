{
  description = "";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      nix-index-database,
      vscode-server,
      ...
    }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem;
      inherit (home-manager.lib) homeManagerConfiguration;
      nixRegistry = {
        nix.registry = builtins.mapAttrs (_: input: { flake = input; }) inputs;
      };
      nixosModules = [
        nixRegistry
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = homeManagerModules;
          };
        }
        vscode-server.nixosModules.default
      ];
      homeManagerModules = [
        nixRegistry
        nix-index-database.hmModules.nix-index
      ];
      mkSystem = entrypoint: nixosSystem { modules = nixosModules ++ [ entrypoint ]; };
    in
    {
      nixosConfigurations = {
        yakirevich = mkSystem ./configuration.nix;
      };
    };
}
