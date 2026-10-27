{
  nixpkgs ? {
    outPath = (import ../lib).cleanSource ./..;
    revCount = 56789;
    shortRev = "gfedcba";
  },
  stableBranch ? false,
}:
let
  pkgs = import ./.. { system = "aarch64-linux"; };
  lib = pkgs.lib;
  version = lib.fileContents ../.version;
  versionSuffix =
    (if stableBranch then "." else "pre") + "${toString nixpkgs.revCount}.${nixpkgs.shortRev}";
in
{
  channel = import ./lib/make-channel.nix {
    inherit
      pkgs
      nixpkgs
      version
      versionSuffix
      ;
  };
}
