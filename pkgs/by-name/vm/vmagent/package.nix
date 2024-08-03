{ lib, victoriametrics }:

# This package is build out of the victoriametrics package.
# so no separat update prs are needed for vmagent
# nixpkgs-update: no auto update
lib.addMetaAttrs
  {
    mainProgram = "vmagent";
    # Add position, so that nixpkgs-update uses this for update parsing
    # (including ignore definitions) and not victoriametrics derivation
    position = toString ./package.nix + ":1";
  }
  (
    victoriametrics.override {
      withServer = false;
      withVictoriaLogs = false;
      withVmAlert = false;
      withVmAuth = false;
      withBackupTools = false;
      withVmctl = false;
      withVmAgent = true;
    }
  )
