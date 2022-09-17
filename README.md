# Nix Config Flake
### This repo host a flake which contains NixOS and Home Manager configurations
This git repository contains a nix flake used to configure the systems I work with using home-manager and NixOS.

Much of the code is borrowed from other public examples of combined home-manager and NixOS flakes, however it is important to note what is specific about this repo.

The code here assumes that the owner (me) works across many different kinds of computers and OS's, sometimes in NixOS machines, sometimes on other flavors of Linux, and sometimes in Linux VM's without control of the system GUI (e.g. Chromebooks).  As such, the NixOS configs only contain enough config to setup the unique hardware for a given host, and a base layer, and as much as possible is delegated to the home-manager layer, so that it can be consistent across machines, whether NixOS or not.

Finally, the config is broken apart into 'mixins', which contain configuration which may be used across different kinds of machines.  There is common config, shared across all hosts, code that is specific to running a user GUI (e.g. sway config), code that is specific to running GUI on non-NixOS hosts (e.g. nixGL, used to bridge between non-NixOS graphics drivers and nix binaries), etc.  Machine configurations pick and choose the mixins they use, and contain any machine-specific configuration.

# On Flakes and Home Manager
A flake-based configuration of home-manager is just the result of calling the home-manager.lib.homeManagerConfiguration function.

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
