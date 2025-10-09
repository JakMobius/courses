.PHONY: all compile watch clean

all: compile;

compile:
	typst compile --root ../.. main.typ cheat-sheet.pdf

watch:
	typst watch --root ../.. main.typ cheat-sheet.pdf

clean:
	rm cheat-sheet.pdf