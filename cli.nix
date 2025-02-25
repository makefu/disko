{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, mode ? "mount"
, flake ? null
, flakeAttr ? null
, diskoFile ? null
, rootMountPoint ? "/mnt"
, noDeps ? false
, ...
}@args:
let
  disko = import ./. {
    inherit rootMountPoint;
    inherit lib;
  };

  diskoAttr =
    if noDeps then
      {
        create = "createScriptNoDeps";
        mount = "mountScriptNoDeps";
        zap_create_mount = "diskoNoDeps";
        disko = "diskoNoDeps";
      }.${mode}
    else
      {
        create = "createScript";
        mount = "mountScript";
        zap_create_mount = "diskoScript";
        disko = "diskoScript";
      }.${mode};

  hasDiskoConfigFlake =
    diskoFile != null || lib.hasAttrByPath [ "diskoConfigurations" flakeAttr ] (builtins.getFlake flake);

  hasDiskoModuleFlake =
    lib.hasAttrByPath [ "nixosConfigurations" flakeAttr "config" "disko" "devices" ] (builtins.getFlake flake);

  diskFormat =
    let
      diskoConfig =
        if diskoFile != null then
          import diskoFile
        else
          (builtins.getFlake flake).diskoConfigurations.${flakeAttr};
    in
    if builtins.isFunction diskoConfig then
      diskoConfig ({ inherit lib; } // args)
    else
      diskoConfig;

  diskoEval =
    disko.${diskoAttr} diskFormat pkgs;

  diskoScript =
    if hasDiskoConfigFlake then
      diskoEval
    else if (lib.traceValSeq hasDiskoModuleFlake) then
      (builtins.getFlake flake).nixosConfigurations.${flakeAttr}.config.system.build.${diskoAttr}
    else
      (builtins.abort "neither diskoConfigurations.${flakeAttr} nor nixosConfigurations.${flakeAttr} found");

in
diskoScript
