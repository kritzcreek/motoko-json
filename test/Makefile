MOC?=./moc

all:
	$(MOC) $(shell vessel sources) -wasi-system-api test.mo
	wasmtime test.wasm

clean:
	rm -f test.wasm
