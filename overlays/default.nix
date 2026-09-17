# オーバーレイ集合の入口。
# 適用順序: compat → inputs → nur → (local-packages はタスク 2.3 で追加)
flakeInputs:
let
  compat = import ./compat.nix flakeInputs;
  inputsOverlay = import ./inputs.nix flakeInputs;
  nur = import ./nur.nix flakeInputs;
in
{
  default =
    final: prev:
    builtins.foldl' (acc: overlay: acc // overlay final acc) prev [
      compat
      inputsOverlay
      nur
    ];
  inherit compat;
  inputs = inputsOverlay;
  inherit nur;
}
