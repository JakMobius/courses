.PHONY: all compile watch clean

ARGS=--root .. --font-path ../theme/fonts
NAME=$(shell basename $(CURDIR))

all: compile;

compile:
	typst compile main.typ ${ARGS} "${NAME}.pdf"

watch:
	typst watch main.typ ${ARGS} "${NAME}.pdf"
	
format:
	typstfmt *.typ

clean:
	rm -rf "${NAME}.pdf"
