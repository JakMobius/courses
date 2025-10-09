.PHONY: all compile watch clean

.FORCE: ;

ARGS=--root .. --font-path ../theme/fonts
NAME=$(shell basename $(CURDIR))

all: compile cheat-sheet;

compile:
	typst compile main.typ ${ARGS} "${NAME}.pdf"

watch:
	typst watch main.typ ${ARGS} "${NAME}.pdf"
	
format:
	typstfmt *.typ

cheat-sheet: .FORCE
	make -C cheat-sheet

clean:
	rm -rf "${NAME}.pdf"
