#!/bin/bash
# Script to fix Rust linking issues for super_drag_and_drop

# Set environment variables to force gcc as linker
export RUSTFLAGS="-C linker=gcc -C link-arg=-lpthread -C link-arg=-ldl -C link-arg=-lrt"
export CARGO_BUILD_RUSTFLAGS="-C linker=gcc -C link-arg=-lpthread -C link-arg=-ldl -C link-arg=-lrt"
export CC=gcc
export CXX=g++

# Clean Rust cache
cd rust
cargo clean

# Build Rust library with gcc
cargo build --release

# Return to project root
cd ..

# Build Flutter app
flutter build linux --debug
