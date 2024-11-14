{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation {
  inherit (python3Packages.flit-core)
    pname
    version
    src
    meta
    patches
    ;
  sourceRoot = python3Packages.flit-core.sourceRoot or null;
  nativeBuildInputs = [
    pyprojectHook
  ];
}
