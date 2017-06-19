{ helpers, pkgs }:
with pkgs;
runCommand "check-tex" {}
  ''
    DIR="/home/chris/Documents/ArchivedPapers"

    function exists {
      if [[ -e "$1" ]]
      then
        echo "Found '$1'"
        return
      fi

      if [[ -e "$DIR/$1" ]]
      then
        echo "Found '$DIR/$1'"
        return
      fi

      B=$(basename "$1")
      for PREFIX in "/home/chris/Documents" "/home/chris/Documents/ArchivedPapers"
      do
        if [[ -e "$PREFIX/$B" ]]
        then
            echo "No such file '$1', but did find '$PREFIX/$B'" 1>&2
            exit 1
        fi
      done

      echo "Could not find $1" 1>&2
      exit 1
    }

    echo "Checking localfiles exist"

    BIB="/home/chris/Writing/Bibtex.bib"

    exists "$BIB"

    while read -r FILE
    do
      echo "Checking '$FILE'"
      exists "$FILE"

      NORM=$(basename "$FILE" | tr '[:upper:]' '[:lower:]')
      EXT=$(echo "$NORM" | rev | cut -d '.' -f 1   | rev)
      ALLOWED=0
      for OKEXT in pdf html
      do
        [[ "x$EXT" = "x$OKEXT" ]] && ALLOWED=1
      done
      if [[ "$ALLOWED" -eq 1 ]]
      then
        echo "'$FILE' has acceptable filename"
      else
        echo "Filename '$FILE' indicates an invalid format" 1>&2
        exit 1
      fi
    done < <(grep -o 'localfile[ \t]*=[ \t]*".*"' < "$BIB" |
             grep -o '".*"'                                |
             grep -o '[^"]*')

    echo "Trying bibclean"

    RAWBIB=$(nix-shell -p bibclean \
                       --run "bibclean -output-file /dev/null 2>&1 < $BIB") || {
      echo "bibclean exited with code '$?'" 1>&2
      echo "RAWBIB: $RAWBIB" 1>&2
      exit 1
    }

    # Remove stuff we don't care about; if there's anything remaining, fail
    KEEP=$(echo "$RAWBIB"                         |
           grep "[^ ]"                            |
           grep -v "ISBN"                         |
           grep -v "http://dx.doi.org"            |
           grep -v "Unexpected value in ..pages"  |
           grep -v "Unexpected value in ..volume" |
           grep -v "Unexpected value in ..month")

    if [[ -z "$KEEP" ]]
    then
      echo "No suspicious output from bibclean"
    else
      echo "bibclean gave the following suspicious output:" 1>&2
      echo "$KEEP" 1>&2
      exit 1
    fi

    echo "Trying bibtool"

    RAWBIB=$(nix-shell -p bibtool --run "bibtool < $BIB 2>&1 1> /dev/null") || {
      echo "bibtool exited with code $?" 1>&2
      echo "$RAWBIB" 1>&2
      exit 1
    }

    if [[ -z "$RAWBIB" ]]
    then
      echo "No suspicious output from bibtool"
    else
      echo "bibtool gave the following suspicious output" 1>&2
      echo "$RAWBIB" 1>&2
      exit 1
    fi

    echo "Trying bibtex"

    TMP="/tmp/check-tex-temp"
    [[ -e "$TMP" ]] && rm -rf "$TMP"

    mkdir -p "$TMP"
    pushd "$TMP"

    cat << 'EOF' > "check-tex.tex"
    \documentclass{article}
    \begin{document}
    \nocite{*}
    \bibliographystyle{plain}
    \bibliography{/home/chris/Writing/Bibtex}
    \end{document}
    EOF

    if { latex check-tex && bibtex check-tex; }
    then
      echo "Ran latex and bibtex on '$BIB'"
    else
      echo "Error running latex and/or bibtex" 1>&2
      exit 1
    fi

    popd

    echo "Checking for dodgy keys"

    if grep "^@misc{zzzzz" < "$BIB"
    then
      echo "Dodgy keys found; either look up a proper citation, or remove them"
    fi

    echo "pass" > "$out"
    exit 0

    # Other tools to try:
    lacheck
    ChkTeX
    "http://www.ctan.org/tex-archive/support/check/"
''
