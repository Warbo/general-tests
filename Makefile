# All filenames from scripts/
tests := $(notdir $(wildcard scripts/*))

attrs := $(shell ./helpers/attrnames.sh)

attrpasses := $(addprefix results/pass/, $(attrs))

# Success indicators. 'results/pass/foo' indicates success of 'scripts/foo'
passes := $(addprefix results/pass/, $(tests))

# To have all tests pass means having all dummy files in place
all : $(passes) $(attrpasses)

# Each dummy file depends on its associated script
$(passes) : $(addprefix scripts/, $(notdir $@))
	./helpers/prepare.sh $(notdir $@)
	scripts/$(notdir $@) 1> results/stdout/$(notdir $@) \
	                     2> results/stderr/$(notdir $@)
	./helpers/pass.sh $(notdir $@)

$(attrpasses) :
	./helpers/prepare.sh $(notdir $@)
	./helpers/runscript.sh $(notdir $@) 1> results/stdout/$(notdir $@) \
	                                    2> results/stderr/$(notdir $@)
	./helpers/pass.sh $(notdir $@)

.PHONY: clean

clean :
	rm -f results/pass/*
	rm -f results/stdout/*
	rm -f results/stderr/*
	rm -f results/running/*
	rm -f results/check/*
	rm -f results/attrs.json
