# All filenames from scripts/
tests := $(notdir $(wildcard scripts/*))

# Success indicators. 'results/pass/foo' indicates success of 'scripts/foo'
passes := $(addprefix results/pass/, $(tests))

# To have all tests pass means having all dummy files in place
all : $(passes)

# Each dummy file depends on its associated script
$(passes) : $(addprefix scripts/, $(notdir $@))
	mkdir -p results/stdout results/stderr
	mkdir -p results/pass results/running results/check
	touch results/running/$(notdir $@)
	scripts/$(notdir $@) 1> results/stdout/$(notdir $@) \
	                     2> results/stderr/$(notdir $@)
	touch results/pass/$(notdir $@)
	rm -f results/running/$(notdir $@)
	rm -f results/check/$(notdir $@)

clean :
	rm -f results/pass/*
	rm -f results/stdout/*
	rm -f results/stderr/*
	rm -f results/running/*
	rm -f results/check/*
