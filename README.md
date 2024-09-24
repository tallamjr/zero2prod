[![codecov](https://codecov.io/gh/tallamjr/zero2prod/graph/badge.svg?token=rPdbh2HJco)](https://codecov.io/gh/tallamjr/zero2prod)

# Zero to Production Notes

## Chapter 1: Getting Started

### Install/update rustup:

```console
$ curl https://sh.rustup.rs -sSf | sh -s -- -y && source "$HOME/.cargo/env"
```

### CI, Formatting, etc.

```console
$ cargo llvm-cov
$ cargo fmt -- --check
$ cargo install cargo-audit
```

Fail the linter check if clippy emits any warnings

```console
$ cargo clippy -- -D warnings
```

```console
$ cargo watch -x check -x test -x run
```

### Toolchain

Install linker for macOS:

```console
$ brew install keith/formulae/ld64.lld
```

[mold/sold linker](https://github.com/rui314/mold) might be worth considering. Unsure of licesne situation and
usage considering updates with Xcode 15 that has a more improved linker now.

> We are considering relicensing the sold linker as free software rather than as
> a commercial product, given the recent developments with the official Apple
> linker. Since Apple's linker has gained speed, it's difficult to obtain a
> sufficient number of users to sustain this project.

With the confusing state of play with license I would opt for using mold only for
linux builds and ld64.lld for macOS builds.

Having said that, with the latest release of Xcode 15 on macOS, there is talk
that the new default `ld` linker is much faster for `Mach-O` targets (note,
`ld-prime` was the initial name for the new linker in Xcode 15 beta, but that
has now changed to be just `ld` and the _old_ version being called `ld-classic`.

#### Refs:

- [Trialling the Xcode 15 beta linker](https://www.reddit.com/r/rust/comments/141z6fs/trialling_the_xcode_15_beta_linker/)
- [`zld` is now archived, consider using lld instead](https://github.com/michaeleisel/zld#note-zld-is-now-archived-consider-using-lld-instead-more-info-is-here)
- [Michael Eisel's Blog aka Mr `zld`](https://eisel.me/lld)

_Anyways_ ..

1. Toolchain, installed. ✅
2. Project skeleton, done. ✅
3. IDE, ready ✅

## Chapter 2: Building An Email Newsletter

User Stories:

      - As a blog visitor,
      - I want to subscribe to the newsletter,
      - So that I can receive email updates when new content is published on the blog;

      - As the blog author,
      - I want to send an email to all my subscribers,
      - So that I can notify them when new content is published.

## Chapter 3: Sign Up A New Subscriber

1. Choose a web framework and get familiar with it;
2. Define our testing strategy;
3. Choose a crate to interact with our database (we will have to save those emails somewhere!);
4. Define how we want to manage changes to our database schemas over time (a.k.a. migrations);
5. Actually write some queries

```console
$ curl http://127.0.0.1:8000
Hello World!

```

`cargo expand` for expanding procedural macros, typicall requires `+nightly`
toolchain: can then run via `cargo +nightly expand` (and is installed via `cargo
install cargo-expand`)

## Chapter 4: Telemetry

## Chapter 5: Going Live

## Chapter 6: Reject Invalid Subscribers \#1

## Chapter 7: Reject Invalid Subscribers \#2

## Chapter 8: Error Handling

## Chapter 9: Naive Newsletter Delivery

## Chapter 10: Securing Our API

## Chapter 11: Fault-tolerant Workflows

```

```
