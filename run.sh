#!/bin/zsh
moc -wasi-system-api $(vessel sources) test.mo && wasmtime test.wasm
