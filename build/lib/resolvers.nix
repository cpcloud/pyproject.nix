{ lib, ... }:

let
  inherit (lib)
    concatMap
    attrNames
    elemAt
    genericClosure
    match
    genAttrs
    throwIf
    ;

in
{
  /*
    Resolve dependencies using a non-circular supporting approach.

    This implementation is faster than the one supporting circular dependencies, and is memoized.

    `resolveNonCyclic` is intended to resolve build-system dependencies.
  */
  resolveNonCyclic =
    # List of package names to memoize
    memoNames:
    # Package set to resolve packages from
    set:
    let
      recurse' =
        name: extras:
        let
          pkg = set.${name};
          dependencies = pkg.passthru.dependencies or { };
        in
        [ name ]
        ++ concatMap (name: recurse name dependencies.${name}) (attrNames dependencies)
        ++ concatMap (
          name':
          let
            extra' = pkg.passthru.optional-dependencies.${name'} or { };
            group' = pkg.passthru.dependency-groups.${name'} or { };
          in
          throwIf (extra' == { } && group' == { })
            "Extra/group name '${name'}' does not match either extra or dependency group"
            concatMap
            (name: recurse name extra'.${name})
            (attrNames extra')
          ++ concatMap (name: recurse name group'.${name}) (attrNames group')
        ) extras;

      # Memoise known build systems with no extras enabled for better performance
      memo = genAttrs memoNames (name: recurse' name [ ]);

      recurse =
        name: extras: if extras == [ ] then (memo.${name} or (recurse' name [ ])) else recurse' name extras;
    in
    # Attribute set of dependencies -> extras { requests = [ "socks" ]; }
    spec: concatMap (name: recurse name spec.${name}) (attrNames spec);

  /*
    Resolve dependencies using a cyclic supporting approach.

    `resolveCyclic` is intended to resolve virtualenv dependencies.
  */
  resolveCyclic =
    # Package set to resolve packages from
    set:
    # Attribute set of dependencies -> extras `{ requests = [ "socks" ]; }`
    spec:
    let
      mkKey = key: { inherit key; };

      # Resolve spec recursively
      closure' = genericClosure {
        startSet = concatMap (
          name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") spec.${name}
        ) (attrNames spec);
        operator =
          { key }:
          let
            m = match "(.+)@(.*)" key;
          in
          # We're looking for a package with extra or dependency group
          if m != null then
            (
              let
                pkg = set.${elemAt m 0};
                name' = elemAt m 1;
                extras' = pkg.passthru.optional-dependencies.${name'} or { };
                groups' = pkg.passthru.dependency-groups.${name'} or { };
                nn = builtins.trace pkg.name name';
                disabled = lib.traceVal (set.${nn}.disabled or false);
              in
              throwIf (!disabled && extras' == { } && groups' == { })
                "Extra/group name '${name'}' does not match either extra or dependency group"
                (
                  concatMap (name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") extras'.${name}) (
                    attrNames extras'
                  )
                  ++ concatMap (name: [ (mkKey name) ] ++ map (group: mkKey "${name}@${group}") groups'.${name}) (
                    attrNames groups'
                  )
                )
            )
          # Root package with no extra
          else
            (
              let
                pkg = set.${key};
                dependencies = pkg.passthru.dependencies or { };
              in
              concatMap (name: [ (mkKey name) ] ++ map (extra: mkKey "${name}@${extra}") dependencies.${name}) (
                attrNames dependencies
              )
            );
      };

      # closure' contains a list like [ { key = "dep@extra"; }]
      # where each dependency containing an extra is a duplicate of it's non-extra enabled
      closure = lib.filter (dep: match ".+@.*" dep.key == null) closure';

    in
    map (dep: dep.key) closure;
}
