{ helpers, pkgs }:
with pkgs;
with rec {
  checkShebang = wrap {
    name   = "check-shebang";
    script = ''
      #!/usr/bin/env bash
      script="$1"

      SHEBANG=$(head -n 1 < "$script")*/
      if echo "$SHEBANG" | grep "#![ ]*/bin/sh" > /dev/null
      then
        echo "#!/bin/sh in $script may break on Debian (dash)" 1>&2
        exit 1
      fi

      if echo "$SHEBANG" | grep "#![ ]*/bin/bash" > /dev/null
      then
        echo "#!/bin/bash in $script won't work on NixOS" 1>&2
        exit 1
      fi

      if   echo "$SHEBANG" | grep "#![ ]*/usr/bin" > /dev/null &&
         ! echo "$SHEBANG" | grep "/usr/bin/env"   > /dev/null
      then
        echo "Shebang for $script may not work on NixOS"
        exit 1
      fi

      exit 0
    '';
  };

  checkScripts = dir: wrap {
    name   = "check";
    paths  = [ bash ];
    vars   = { inherit checkShebang dir; };
    script = ''
      #!/usr/bin/env bash
      set -e
      while read -r script
      do
        "$checkShebang" "$script" || exit 1
      done < <(find "$dir" -name "*.sh")
      exit 0
    '';
  };
};
{
  tests = checkScripts (latestGit {
    url    = "http://chriswarbo.net/git/general-tests.git";
    stable = { unsafeSkip = true; };
  });

  warbo-utilities = checkScripts (latestGit {
    url    = "http://chriswarbo.net/git/warbo-utilities.git";
    stable = { unsafeSkip = true; };
  });
}
