let
  partitions = [
    "channels"
    "schemas"
    "systems"
  ];

  mkPartition = partition: {
    partitions.${partition}.extraInputsFlake = ../partitions/${partition};
  };
in
{
  imports = map mkPartition partitions;
}
