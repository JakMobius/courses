.PHONY: all compile watch handout clean

ARGS=--root .. --font-path ../theme/fonts
NAME=$(shell basename $(CURDIR))

all: compile handout;

compile:
	typst compile main.typ ${ARGS} "${NAME}-class.pdf"

watch:
	typst watch main.typ ${ARGS} "${NAME}-class.pdf"
	
handout:
	typst compile --input handout=true main.typ ${ARGS} "${NAME}.pdf"

format:
	typstfmt *.typ

clean:
	rm -rf "${NAME}-class.pdf" "${NAME}.pdf"
