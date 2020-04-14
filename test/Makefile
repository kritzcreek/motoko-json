MOC?=./moc
PKGS=$(shell vessel --package-set ../package-set.json sources)
all:
	$(MOC) $(PKGS) -wasi-system-api test.mo
	wasmtime test.wasm

clean:
	rm -f test.wasm
