#!/bin/sh

# get env
current_env="${devenv}"

# Node
if [ "$current_env" == "node" ]
then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
fi

# Rust
if [ "$current_env" == "rust" ]
then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly --profile=default --component rls
    source $HOME/.cargo/env && cargo install diesel_cli --no-default-features --features "sqlite"
fi

# Clojure
if [ "$current_env" == "clojure" ]
then
    curl -o- https://download.clojure.org/install/linux-install-1.10.1.492.sh | sudo bash
fi
