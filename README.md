
Install/update rustup:

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y && source "$HOME/.cargo/env"
brew install keith/formulae/ld64.lld
cargo +stable install cargo-llvm-cov --locked
cargo llvm-cov
cargo clippy -- -D warnings
cargo fmt -- --check
cargo install cargo-audit
```

mold/sold linker. Worth checking out.

https://github.com/rui314/mold
