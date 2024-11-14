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
    ;
  patches = null;
  doCheck = false;
  nativeBuildInputs = [
    pyprojectHook
  ];
}
