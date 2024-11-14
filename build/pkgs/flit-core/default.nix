{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation rec {
  inherit (python3Packages.flit-core)
    pname
    version
    src
    meta
    patches
    format
    ;
  prePatch = "exit 1";
  postPatch = "exit 1";#cd flit_core";
  nativeBuildInputs = [
    pyprojectHook
  ];
}
