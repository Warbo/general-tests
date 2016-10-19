with import <nixpkgs> {};
with builtins;

let
getProjects = runCommand "projects"
  {
    buildInputs = [ findutils gnused ];
    LOCATE_PATH = getEnv "LOCATE_PATH";
  }
  ''
    #!${bash}/bin/bash

    function skip {
      grep -v "/NotMine/"                         |
      grep -v "/git-html/"                        |
      grep -v "/ghc/"                             |
      grep -v "/quickspec"                        |
      grep -v "/unification"                      |
      grep -v "/structural-induction"             |
      grep -v "haskell-te/cache/"                 |
      grep -v "haskell-te/packages"
    }

    function dirs {
      while read -r CBL
      do
        if grep "test-suite" < "$CBL" > /dev/null
        then
          dirname "$CBL"
        fi
      done < <(locate -e "/home/chris/Programming/*.cabal" | skip)
    }

    function data {
      echo "["
      dirs
      echo "]"
    }

    data > "$out"
  '';

projects = import "${getProjects}";

cabal = "${haskellPackages.cabal-install}/bin/cabal";

mkTest = dir: writeScript "cabal-test" ''
  #!${racket}/bin/racket
  #lang racket
  (require racket/system)

  (define dir "${dir}")

  (define tmp
    (path->string
      (make-temporary-file "cabal-test-temp-~a" 'directory)))

  (define src
    (string-append tmp "/src"))

  (define (run-suite suite)
    (unless (system* "${cabal}" "test" suite)
      (error "Failed to run suite " suite)))

  (define (suites-from cbl)
    (define test-lines
      (filter (lambda (line)
                (string-contains? (string-downcase line) "test-suite"))
              (file->lines cbl)))

    (map (lambda (line)
           (second (string-split (string-trim line) " ")))
         test-lines))

  (dynamic-wind
    (lambda () #f)
    (lambda ()
      (copy-directory/files dir src)

      (parameterize ([current-directory src])
        (eprintf "Configuring\n")
        (unless (system* "${warbo-utilities}/bin/hsConfig")
          (error "Failed to configure"))

        (define cabal-files
          (find-files (lambda (name)
                        (string-suffix? (path->string name) ".cabal"))))
        (eprintf "Found following cabal files: ~a\n" cabal-files)

        (for-each (lambda (cbl)
                    (define suites
                      (suites-from cbl))
                    (eprintf "Found following test suites: ~a\n" suites)

                    (for-each run-suite suites))
                  cabal-files)))
    (lambda ()
      (delete-directory/files tmp)))

  ;;while read -r HPC
  ;;do
  ;;  echo "Storing coverage report from '$HPC'"
  ;;  mkdir -p ~/Programming/coverage/"$NAME"
  ;;  cp -vr "$HPC" ~/Programming/coverage/"$NAME/"
  ;;done < <(find . -type d -name html)
'';

in listToAttrs (map (p: { name = toString p; value = mkTest p; }) projects)
