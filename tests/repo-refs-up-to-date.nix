# Test whether projects which refer to particular git revisions of other
# projects are using the most up to date revision. Note that we don't include
# all such references: projects which "just work" can be left alone; only those
# which have constant churn are worth checking.
{ helpers, pkgs }:
with pkgs;
with pkgs.lib;
with {
  refs = {
    nix-helpers     = [ "warbo-packages"  ];
    warbo-packages  = [ "warbo-utilities" ];
    warbo-utilities = [ "nix-config"      ];
  };

  check = repo: refs: genAttrs refs (ref: wrap {
    name = "check-${repo}-ref-in-${ref}";
    vars = {
      inherit repo;
      rev = gitHead { url = helpers.repoOf repo; };
      ref = latestGit {
        url    = helpers.repoOf ref;
        stable = { unsafeSkip = true; };
      };
    };
    script = ''
      #!/usr/bin/env bash
      set -e
      # Git commit IDs are pseudorandom, so we only need to find a single match
      # to be confident that this reference is up to date.
      GOTREPO=0
      GOTREV=0
      SHORT=$(echo "$rev" | cut -c1-7)
      while read -r F
      do
        grep "$repo"   < "$F" || continue
        GOTREPO=1
        grep "$SHORT"  < "$F" || continue
        GOTREV=1
      done < <(find "$ref" -name '*.nix')

      [[ "$GOTREPO" -eq 1 ]] || fail "No reference to '$repo' in '$ref'"
      [[ "$GOTREV"  -eq 1 ]] ||
        fail "Repo '$ref' not using latest rev '$SHORT' ('$rev') for '$repo'"
    '';
  });
};
mapAttrs check refs
