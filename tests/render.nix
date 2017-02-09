{ pkgs, helpers }:

with rec {
  inherit (pkgs)
    stdenv;

  inherit (helpers)
    findRepo;
};
{
  test = stdenv.mkDerivation {
           name = "writing";
           src  = findRepo "writing" <writing>;
           buildCommand = ''
             while read -r SCRIPT
             do
               DIR=$(dirname "$SCRIPT")
               pushd "$DIR"
               ./render.sh || {
                 echo "$SCRIPT failed" 1>&2
                 exit 1
               }
               popd
             done < <(find "$src" -name "render.sh")
           '';
         };
}
