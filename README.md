# Douglas Mayle's Nix Config Flake
## About This Flake
### Contained in this flake:
 * NixOS configurations
 * Home Manager configurations
 * Development shells for projects I work on that don't have their own flakes
### Properties of this flake:
 * Configs support `roles` and `profiles`, where profiles are logical groupings of configuration, and roles are logical groupings of profiles.
 * Shared package repo for my custom packages
 * Shared modules repo for my custom modules
 * Custom lib used in this flake
 * Separation of concerns:
   * Main flake loads lib and uses it to load configs (TODO)
   * Separate directories for configs, roles, modules, packages, etc.

### On NixPkgs in Configurations
At this point, for flakes there is no such thing as system, instead there is just a set of packages (which is itself system-dependent).

Since I want to be able to support home-manager for a MacOS system (or an arm one), then there needs to be a way to select a different set of nixpkgs
### This repo host a flake which contains NixOS and Home Manager configurations
This git repository contains a nix flake used to configure the systems I work
with using home-manager and NixOS.

Much of the code is borrowed from other public examples of combined
home-manager and NixOS flakes, however it is important to note what is specific
about this repo.

The code here assumes that the owner (me) works across many different kinds of
computers and OS's, sometimes in NixOS machines, sometimes on other flavors of
Linux, and sometimes in Linux VM's without control of the system GUI (e.g.
Chromebooks).  As such, the NixOS configs only contain enough config to setup
the unique hardware for a given host, and a base layer, and as much as possible
is delegated to the home-manager layer, so that it can be consistent across
machines, whether NixOS or not.

Finally, the config is broken apart into 'mixins', which contain configuration
which may be used across different kinds of machines.  There is common config,
shared across all hosts, code that is specific to running a user GUI (e.g. sway
config), code that is specific to running GUI on non-NixOS hosts (e.g. nixGL,
used to bridge between non-NixOS graphics drivers and nix binaries), etc.
Machine configurations pick and choose the mixins they use, and contain any
machine-specific configuration.

# Commands to run
```
nix path-info --derivation .#homeConfigurations.<hostname>.activationPackage
nix path-info --derivation .#nixosConfigurations.<hostname>.config.system.build.toplevel
```
# Roles, profiles, and configs
There are three basic types on parade here:
 * Configs represent a top-level configuration, either Home Manager, or NixOS,
   and an individual config can have roles, or even specific profiles.
 * Profiles represent configuration that has been broken down by concept
 * Roles represent a grouping of profiles common to that role

# Some musings on Flakes and Nix
The end result that we care about is top-level attribute mapping to the result
of calling the nixosSystem or homeManagerConfiguration function. All the rest
of this structure is about refactoring and making it simple to organize code.
I want to explore the loading methods available to us and write about them here
(e.g. imports attribute, vs. manually merging vs. preloading code vs. overlays)

The imports attribute is a list of paths that will be called, and results
merged. It's a recursive mechanism for merging

# Overlays
The purpose of an overlay is to alter some part of the config tree such that
other code in the config tree uses the altered part. (If we only care about
changing a package, you can just create your own package and use it. If you
need to make a change such that an existing module or an existing package that
uses a specific package now uses your changed package, than you need an
overlay)

# On Flakes and Home Manager
A flake-based configuration of home-manager is just the result of calling the
home-manager.lib.homeManagerConfiguration function.

# Docs
<dl>
  <dt>homeManagerConfiguration</dt>
  <dd><a href="https://nix-community.github.io/home-manager/index.html#ch-nix-flakes">Manual</a></dd>
  <dd><a href="https://github.com/nix-community/home-manager/blob/master/flake.nix#L42">Code</a></dd>
  <dt>nixosSystem</dt>
  <dd><a href="https://github.com/NixOS/nixpkgs/blob/master/flake.nix#L22">Code</a></dd>
</dl>

# Directory Structure
<dl>
  <dt>HomeConfigs</dt>
  <dd>Each file in this sub-directory contains a named Home Manager configuration</dd>
  <dt>NixOSConfigs</dt>
  <dd>Each file in this sub-directory contains a named NixOS configuration</dd>
  <dt>Mixins</dt>
  <dd>Each file in this sub-directory contains configuration that can be imported and used in multiple configurations.</dd>
  <dt>Packages</dt>
  <dd>Each file or module in this directory is for a single package custom to this flake</dd>
  <dt>Overlays</dt>
  <dd>This directory contains nixpkgs overlay functions inside of a default.nix file.</dd>
  <dt>Lib</dt>
  <dd>This directory contains helper functions used by the rest of this repository.</dd>
</dl>

# V2 Notes
## Outputs
This top-level flake has four significant outputs:
1. Packages: any custom packages I've written, either for packages that will never be in nixpkgs, or a staging area before that's ready
2. NixOS configurations: just enough to get a machine working, and anything hardware-linked (e.g. some games stuff)
3. Home Manager configurations: the majority of my config, tailoring things so they're just right no matter the host
4. Dev Shells: Configs for custom environments used just for software development / tinkering

## Structure
 * Library code: custom code used by this flake to make it easier to read and write
 * Package configuration: nixpkgs needs global configuration for licensing and hardware support, this happens here
 * Overlays: nixpkgs as it's made available to my configs needs to contain my custom packages
 * Roles, Profiles, Configs: explained above, Home Manager and NixOS Configs have this breakdown to make them composable across hosts
