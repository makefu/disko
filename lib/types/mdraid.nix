{ config, options, lib, diskoLib, ... }:
{
  options = {
    type = lib.mkOption {
      type = lib.types.enum [ "mdraid" ];
      internal = true;
      description = "Type";
    };

    name = lib.mkOption {
      type = lib.types.str;
      description = "Name";
    };
    _meta = lib.mkOption {
      internal = true;
      readOnly = true;
      type = lib.types.functionTo diskoLib.jsonType;
      default = dev: {
        deviceDependencies.mdadm.${config.name} = [ dev ];
      };
      description = "Metadata";
    };
    _create = diskoLib.mkCreateOption {
      inherit config options;
      default = { dev }: ''
        echo "${dev}" >> "$disko_devices_dir"/raid_${config.name}
      '';
    };
    _mount = diskoLib.mkMountOption {
      inherit config options;
      default = { dev }:
        { };
    };
    _config = lib.mkOption {
      internal = true;
      readOnly = true;
      default = _dev: [ ];
      description = "NixOS configuration";
    };
    _pkgs = lib.mkOption {
      internal = true;
      readOnly = true;
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = pkgs: [ pkgs.mdadm ];
      description = "Packages";
    };
  };
}
