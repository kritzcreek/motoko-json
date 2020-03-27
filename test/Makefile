# Makefile for motoko demos

# This works with bash
MOC?=~/code/motoko/src/moc
STDLIB?=~/code/motoko/stdlib/src
PKGS?=$(shell vessel sources)
# we need to specify the output if there is more than one .mo file
OUT=test.wasm

SAMPLES:= test

all:
	$(MOC) --package stdlib $(STDLIB) $(PKGS) -wasi-system-api test.mo
	wasmtime test.wasm

clean:
	rm -f $(OUT)
