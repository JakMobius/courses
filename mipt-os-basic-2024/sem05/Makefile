.PHONY: all compile watch handout clean

.FORCE: ;

ARGS=--root .. --font-path ../theme/fonts
NAME=$(shell basename $(CURDIR))

all: compile handout cheat-sheet;

compile:
	typst compile main.typ ${ARGS} "${NAME}-class.pdf"

watch:
	typst watch main.typ ${ARGS} "${NAME}-class.pdf"
	
handout:
	typst compile --input handout=true main.typ ${ARGS} "${NAME}.pdf"

format:
	typstfmt *.typ

cheat-sheet: .FORCE
	make -C cheat-sheet

clean:
	rm -rf "${NAME}-class.pdf" "${NAME}.pdf"
