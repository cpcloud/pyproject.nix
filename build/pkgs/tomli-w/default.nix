{
  stdenv,
  python3Packages,
  pyprojectHook,
  resolveBuildSystem,
}:
stdenv.mkDerivation {
  inherit (python3Packages.tomli-w)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs =
    [
      pyprojectHook
    ]
    ++ resolveBuildSystem {
      flit-core = [ ];
    };
}
