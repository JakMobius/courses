.FORCE:

SEMS=$(wildcard sem*)

all: $(SEMS)

sem%: .FORCE
	make -C $@
