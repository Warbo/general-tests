#! /usr/bin/env nix-shell
#! nix-shell -p gnumake bash -i bash
make -k -j2 -f <(tail -n+4 "$0") "$@"; exit "$?"

# The shebang trickery above means we can do ./Makefile
# All filenames from scripts/
tests := $(notdir $(wildcard scripts/*))

# Success indicators. 'results/pass/foo' indicates success of 'scripts/foo'
passes := $(addprefix results/pass/, $(tests))

# To have all tests pass means having all dummy files in place
all : $(passes)

# Each dummy file depends on its associated script
$(passes) : $(addprefix scripts/, $(notdir $@))
	scripts/$(notdir $@) 1> results/$(notdir $@).stdout \
	                     2> results/$(notdir $@).stderr
	touch $@

clean :
	rm -f results/pass/*
