{ inputs, ... }:
let
  channels =
    let
      partition = "channels";
    in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  schemas =
    let
      partition = "schemas";
    in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  systems =
    let
      partition = "systems";
    in
    {
      partitions.${partition}.extraInputsFlake = ../partitions/${partition};
    };

  module = {
    imports = [
      channels
      schemas
      systems
    ];
  };
in
module
