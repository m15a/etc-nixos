{ nixos-hardware, ... }:

{
  louise = import ./louise { inherit nixos-hardware; };
  sagnier = import ./sagnier { inherit nixos-hardware; };
  # suzon = import ./suzon;
}
