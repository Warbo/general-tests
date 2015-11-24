# All filenames from scripts/
tests := $(notdir $(wildcard scripts/*))

# Success indicators. 'results/pass/foo' indicates success of 'scripts/foo'
passes := $(addprefix results/pass/, $(tests))

# To have all tests pass means having all dummy files in place
all : $(passes)

# Each dummy file depends on its associated script
$(passes) : $(addprefix scripts/, $(notdir $@))
	mkdir -p results/pass results/stdout results/stderr results/time
	command time --output=results/time/$(notdir $@) \
	             scripts/$(notdir $@) 1> results/stdout/$(notdir $@) \
	                                  2> results/stderr/$(notdir $@)
	cp results/time/$(notdir $@) $@

clean :
	rm -f results/pass/*
	rm -f results/stdout/*
	rm -f results/stderr/*
	rm -f results/time/*