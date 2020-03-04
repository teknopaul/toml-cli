#
# Makefile toml-cli
#

SRC=$(wildcard src/*.rs)

target/x86_64-unknown-linux-musl/release/toml: $(SRC)
	cargo build --release --target=x86_64-unknown-linux-musl
	strip target/x86_64-unknown-linux-musl/release/toml

.PHONY: clean install uninstall run test deb

run:
	cargo run

test:
	cargo test

deb:
	sudo deploy/build-deb.sh

clean:
	cargo clean
	rm -f target/
	mkdir target

install:
	sudo dpkg --install target/toml-cli-*.deb

uninstall:
	sudo dpkg --remove target/toml-cli-*.deb

