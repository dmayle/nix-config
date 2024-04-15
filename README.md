# Douglas Mayle's Personal Nix Config Flake
## About This Flake
The code for this flake is designed to be as simple and readable as possible.
It is also designed to support all of the features that I want from a personal
flake:
 * NixOS configurations for my hosts.
 * Home Manager configurations for my hosts whether or not on NixOS.
 * Development shells for my software projects.
 * Packaged software not yet supported in nixpkgs.

Additionally, I want to impose some additonial contraints upon this flake:
 * Package definitions should be available to system configurations.
 * Development shells should be available to system configurations.
 * Nixpkgs should be configured to my needs and shared across configurations.
 * The packages used by Home Manager on NixOS systems should be in sync.

## Flake Structure
This flake contains a small nix library that supports the needs of a flake. It
is designed to load itself and support loading and working with nix modules.
Additionally, it has configuration-specific helper functions for use with NixOS
and Home Manager configurations.

The configurations in this flake have a specific structure, but none of the
code in the flake and the library are tied to that structure. It can be used
with any nix code that is stored in modules.

## Configuration Structure
My NixOS and Home Manager configurations are split into configurations,
profiles, and roles.

### Configuration
A NixOS or Home Manager configuration is a nix module containing a function
that can be used to configure a system (standard configuration format).
Additionally, the configurations in this repository are required to contain
a file called `system` that specify the system they are expected to work with
(e.g. `x86_64-linux`).

### Role
These are just collections of nix modules from the profiles specified below.
They are a convenience to enable quickly composing related features into
groups.

### Profile
This is where any shareable configuration nix code belongs. These modules may
be grouped into roles for consumption on multiple machines (e.g. desktop-only
modules, laptop-only modules) or imported directly for machines with specific
needs.

# Flake Library (flib)
The library in this flake is broken down into three files:

## Core Library `default.nix`
This is the code that looks the most magic, and is the least written by me. It
bootstraps itself using the module loading code, and then exports all of
functionality from all of the files using nixpkgs extensibility.

## Module Loading `modules.nix`
This module consists of only two functions:
1. `findModules` recurses through a directory to collect all nix modules
   contained within, and exports them all at the top level as an attribute set
   that maps module name to the path of the module.
2. `loadModules` takes a list of paths and returns an attribute set of path
   names to modules by calling `findModules` on each path.

## Configuration Helpers `configs.nix`
This module contains three functions which are useful to the flake:
1. `mkPackages` takes a nixpkgs input, a package configuration, a list of
   overlays, and a system (e.g. `x86_64-linux`), then imports and configures
   the nixpkgs.
2. `mkHomeConfig` takes a configured nixpkgs import, an attribute set of module
   arguments (these become arguments to all modules in the configuration), the
   name of the configuration (unused argument but makes this function
   compatible with mapAttrs) and the path to nix module containing a Home
   Manager configuration.
2. `mkNixosConfig` takes a configured nixpkgs import, an attribute set of module
   arguments (these become arguments to all modules in the configuration), the
   name of the configuration (unused argument but makes this function
   compatible with mapAttrs) and the path to nix module containing a NixOS
   configuration.

# Installation
These instructions are out of date. When I next bootstrap a machine, I will
update them here.  In the meantime, you can read an overview of the process:

## On a NixOS system
1. Follow the NixOS installation instructions in order to get started.
2. Copy the bootstrap NixOS configuration from nixos-configs folder over the
   generated config files.
3. Build the system with the bootstrapped configuration.
4. Clone this flake into the user's home directory and follow the steps below.

## On a Linux system other than NixOS
1. Install the Nix package manager

## Once Nix package manager is installed
1. Instantiate the home-manager command
2. Use home-manager to install this flake

## On a NixOS system that has been bootstrapped
3. Use sudo to install this flake's NixOS config

```
nix path-info --derivation .#homeConfigurations.<hostname>.activationPackage
nix path-info --derivation .#nixosConfigurations.<hostname>.config.system.build.toplevel
```
