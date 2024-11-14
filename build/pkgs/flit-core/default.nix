{
  stdenv,
  python3Packages,
  pyprojectHook,
}:
stdenv.mkDerivation {
  pname = "flit-core";
  format = "pyproject";
  inherit (python3Packages.flit) src patches version;
  inherit (python3Packages.flit-core) meta postPatch;
  nativeBuildInputs = [
    pyprojectHook
  ];
}
