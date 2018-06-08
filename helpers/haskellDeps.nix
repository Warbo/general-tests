# Haskell package requirements which cabal can't guess (e.g. GHC version)
{ haskellPackages, inputFallback, lib, unpack, writeScript, zlib }:
with builtins;
with lib;
with rec {
  withCIncludes = ps: cfg: cfg // {
    includePaths = zipAttrsWith (n: vs: concatLists vs)
                                [ (cfg.includePaths or {}) ps ];
  };

  withLibs = ps: cfg: cfg // {
    libPaths = zipAttrsWith (n: vs: concatLists vs)
                            [ (cfg.libPaths or {}) ps ];
  };

  withGhc = v: cfg: cfg // { ghc = v; };

  withConstraints = cs: cfg: cfg // {
    constraints = (cfg.constraints or []) ++ cs;
  };

  withOurs = pkgs: withPkgs (map inputFallback pkgs);

  withPkgs = pkgs: cfg: cfg // {
    packages = (cfg.packages or []) ++ pkgs;
  };

  withNix = buildInputs: cfg: cfg // {
    buildInputs = (cfg.buildInputs or []) ++ buildInputs;
  };

  # A common dependency which isn't on Hackage
  lazysmallcheck2012 = unpack haskellPackages.lazysmallcheck2012.src;

  # Some packages require the C zlib implementation, so we abbreviate that here
  withZlibDeps = pkgNames: cfg: fold withZlibDep cfg pkgNames;
  withZlibDep  = pkgName:  cfg:
    withNix [ zlib zlib.dev ]
      (withCIncludes { "${pkgName}" = [ "${zlib.dev}/include"           ]; }
        (withLibs    { "${pkgName}" = [ "${zlib}/lib" "${zlib.dev}/lib" ]; }
          cfg));

  # How to merge together the named field from multiple configs
  combine = name: values:
    if elem name [ "buildInputs" "constraints" "packages" ]
       then concatLists values
       else
    if name == "includePaths"
       then zipAttrsWith (_: vs: concatLists vs) values
       else
    if name == "phases"
       then null
       else
    if length values == 1
       then head values
       else trace (toJSON {
                    inherit name values;
                    warning = "Picking arbitrary value";
                  })
                  (head values);
};
rec {
  utils = rec {
    # Generate a suitable cabal.project.local file from the given config (or
    # null if the config doesn't need one)
    genCabalProjectLocal = cfg:
      with {
        constraints = cfg.constraints  or [];
        packages    = cfg.packages     or [];
        includes    = cfg.includePaths or {};
        libs        = cfg.libPaths     or {};
      };
      if cfg ? packages || cfg ? constraints
         then writeScript "cabal.project.local" ''
                ${if packages == []
                     then ""
                     else "packages:"}
                  ${concatStringsSep "\n  " packages}

                ${if constraints == []
                     then ""
                     else "constraints:"} ${concatStringsSep ", " constraints}

                ${fold (pkg: str: ''
                         ${str}

                         package ${pkg}
                           ${concatStringsSep "\n  "
                               ((if hasAttr pkg includes
                                    then [ ("extra-include-dirs: " +
                                             (concatStringsSep ","
                                               (getAttr pkg includes))) ]
                                    else []) ++
                                (if hasAttr pkg libs
                                    then [ ("extra-lib-dirs: " +
                                             (concatStringsSep ","
                                               (getAttr pkg libs))) ]
                                    else []))}
                       '')
                       ""
                       (unique (attrNames includes ++ attrNames libs))}
              ''
         else null;

    # Get config for the given pkgName, merging in any phase-specific config
    # (e.g. for testing or code coverage)
    phaseConfig = pkgName: phase:
      with { cfg = if hasAttr pkgName cfgs then getAttr pkgName cfgs else {}; };
      zipAttrsWith combine
                   [ cfg (if hasAttr phase (cfg.phases or {})
                             then getAttr phase cfg.phases
                             else {}) ];
  };
  cfgs = {
    arbitrary-haskell       = withGhc "ghc7103" {};
    ast-plugin              = withOurs [ "hs2ast" ] {};
    hs2ast                  = withGhc "ghc7103" {};
    k-means                 = withGhc "ghc7103" {};
    lazy-lambda-calculus    = withPkgs [ lazysmallcheck2012 ] {};
    ml4hsfe                 = withGhc "ghc7103" (withOurs [ "hs2ast" ] {});
    mlspec                  = withGhc "ghc7103" (withOurs [ "mlspec-helper" ] {});
    mlspec-helper           = withGhc "ghc7103" {};
    order-deps              = withGhc "ghc7103" (withOurs [ "hs2ast" ] {});
    panhandle               = withGhc "ghc7103"
                                (withPkgs [ lazysmallcheck2012 ]
                                  (withZlibDeps [ "digest" "zlib" ] {
                                    phases = {
                                      coverage = withConstraints [
                                        "haddock-library == 1.4.3"
                                      ] {};
                                    };
                                  }));
    runtime-arbitrary-tests = withGhc "ghc7103" {};
    type-parser             = withGhc "ghc7103" {};
  };
}
