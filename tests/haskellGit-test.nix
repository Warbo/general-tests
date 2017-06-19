{ helpers, pkgs }:
with pkgs;

{
  nixEvalExists = runCommand "nix-eval-exists"
    {
      cfg = latestGit { url = helpers.repoOf "nix-config"; };
    }
    ''
      FOUND=0
      while read -r FILE
      do
        if grep "haskellGit" < "$FILE" > /dev/null
        then
          FOUND=1
        else
          echo "No haskellGit found in '$FILE'" 1>&2
        fi
      done < <(find "$cfg" -name "nix-eval.nix" | grep "haskell")

      if [[ "$FOUND" -eq 1 ]]
      then
        echo "pass" > "$out"
      else
        echo "Couldn't find haskell/nix-eval.nix" 1>&2
        exit 1
      fi
    '';

  nixGitRevEnv = runCommand "nix-giv-rev-env-set"
    {
      buildInputs = [ haskellPackages.nix-eval ];
    }
    ''
      echo "Checking if nix_git_rev_... is set inside nix-shell"
      OUTPUT=$(env | grep nix_git_rev)

      echo "$OUTPUT" | grep "^nix_git_rev_" > /dev/null || {
        echo "No nix_git_rev_... variables were set: $OUTPUT" 1>&2
        exit 1
      }
      echo "pass" > "$out"
  '';

  nestedNixShells = runCommand "nested-nix-shells"
    (withNix { buildInputs = [ coreutils ]; })
    ''
      echo "Running nested nix-shells"
      OUTPUT=$(nix-shell --show-trace -p haskellPackages.nix-eval --run \
                 'nix-shell --show-trace -p haskellPackages.nix-eval --run true' 2>&1)
      echo "$OUTPUT"

      echo "Making sure we only checked git repos at most once"
      SEEN=""
      while read -r LINE
      do
        URL=$(echo "$LINE" | sed -e 's/.*repo-head-//g' | grep -o '[a-z0-9]*')
        STAMP=$(echo "$LINE" | sed -e 's@.*store/@@g' | sed -e 's@-repo-head-.*@@g')
        ENTRY=$(echo -e "$URL\t$STAMP")
        while read -r STAMPS
        do
          FST=$(echo "$STAMPS" | cut -f2)
          SND=$(echo "$STAMPS" | cut -f3)
          if [[ "x$FST" = "x$SND" ]]
          then
            echo "Multiple timestamps for '$URL'" 1>&2
            exit 1
          fi
        done < <(join <(echo "$SEEN") <(echo "$ENTRY"))
        SEEN=$(echo "$SEEN"; echo "$ENTRY")
      done < <(echo "$OUTPUT" | grep "^building path.*repo-head")

      echo "pass" > "$out"
    '';
}
