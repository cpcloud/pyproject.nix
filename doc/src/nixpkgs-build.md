# Build infrastructures

Pyproject.nix can be used with nixpkgs `buildPythonPackage`/`packageOverrides`/`withPackages`, but also implements it's [own build infrastructure](./build.md) that fixes many structural problems with the nixpkgs implementation.