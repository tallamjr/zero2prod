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

See `.cargo/config.toml`:

```toml
# On Windows
# cargo install -f cargo-binutils
# rustup component add llvm-tools-preview
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

[target.x86_64-pc-windows-gnu]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

# On Linux:
# - Ubuntu, sudo apt-get install lld clang
# - Arch, sudo pacman -S lld clang
[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "linker=clang", "-C", "link-arg=-fuse-ld=lld"]

# On MacOS, brew install llvm and follow steps in brew info llvm
[target.x86_64-apple-darwin]
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

[target.aarch64-apple-darwin]
# rustflags = ["-C", "link-arg=-fuse-ld=/opt/homebrew/opt/llvm/bin/ld64.lld"]

# If xcodebuild --version > 15; then use the following
rustflags = ["-C", "link-arg=-fuse-ld=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld"]
```

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

```rust
warning: unused variable: `req`
 --> src/main.rs:8:23
  |
8 | async fn health_check(req: HttpRequest) -> impl Responder {
  |                       ^^^ help: if this is intentional, prefix it with an underscore: `_req`
  |
  = note: `#[warn(unused_variables)]` on by default

warning: `zero2prod` (bin "zero2prod") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.37s

```

```toml
[lib]
# We could use any path here, but we are following the community convention # We could specify a library name using the `name` field. If unspecified,
# cargo will default to `package.name`, which is what we want.
path = "src/lib.rs"

# Notice the double square brackets: it's an array in TOML's syntax.
# We can only have one library in a project, but we can have multiple binaries!
# If you want to manage multiple libraries in the same repository
# have a look at the workspace feature - we'll cover it later on.
[[bin]]
path = "src/main.rs"
name = "zero2prod"

```

```rust
// We need to mark `run` as public.
// It is no longer a binary entrypoint, therefore we can mark it as async
// without having to use any proc-macro incantation.
pub async fn run() -> Result<(), std::io::Error> {
    HttpServer::new(|| App::new().route("/health_check", web::get().to(health_check)))
        .bind("127.0.0.1:8000")?
        .run()
        .await
}
```

> `tokio::test` is the testing equivalent of `tokio::main`.
> It also spares you from having to specify the `#[test]` attribute.

Port 0 is special-cased at the OS level: trying to bind port 0 will trigger an OS scan for an available port which
will then be bound to the application

```rust

    let server = zero2prod::run("127.0.0.1:0").expect("Failed to bind address");

```

#### Refocus

1. How to read data collected in a HTML form in actix-web (i.e. how do I parse the request body of a POST?);
2. What libraries are available to work with a PostgreSQL database in Rust (diesel vs sqlx vs tokio­postgres);
3. How to setup and manage migrations for our database;
4. How to get our hands on a database connection in our API request handlers;
5. How to test for side-effects (a.k.a. stored data) in our integration tests;
6. How to avoid weird interactions between tests when working with a database.

#### Summary

We covered a large number of topics in this chapter:

- actix-web extractors and HTML forms
- (de)serialisation with `serde`
- overview of the available database crates in the Rust ecosystem:
- fundamentals of `sqlx`

```console
$ brew install postgresql

$ cargo install --version="~0.8" sqlx-cli --no-default-features --features rustls,postgres

$ sqlx --help
Command-line utility for SQLx, the Rust SQL toolkit.

Usage: sqlx <COMMAND>

Commands:
  database  Group of commands for creating and dropping your database
  prepare   Generate query metadata to support offline compile-time verification
  migrate   Group of commands for creating and running migrations
  help      Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

$ sqlx database -h
Group of commands for creating and dropping your database

Usage: sqlx database <COMMAND>

Commands:
  create  Creates the database specified in your DATABASE_URL
  drop    Drops the database specified in your DATABASE_URL
  reset   Drops the database specified in your DATABASE_URL, re-creates it, and runs any pending migrations
  setup   Creates the database specified in your DATABASE_URL and runs any pending migrations
  help    Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help

$ sqlx database create

```

##### 🔑 Key Section

3.10.1 Test Isolation

Your database is a gigantic global variable: all your tests are interacting with
it and whatever they leave behind will be available to other tests in the suite
as well as to the following test runs. This is precisely what happened to us a
moment ago: our first test run commanded our application to register a new
subscriber with `ursula_le_guin@gmail.com` as their email; the application
obliged. When we re-ran our test suite we tried again to perform another
`INSERT` using the same email, but our `UNIQUE` constraint on the email column
raised a unique `key violation` and rejected the query,forcing the application
to return us a `500 INTERNAL_SERVER_ERROR`.

You really do not want to have _any_ kind of interaction
between your tests: it makes your test runs nondeterministic and it leads down
the line to spurious test failures that are extremely tricky to hunt down and
fix.

There are two techniques I am aware of to ensure test isolation when
interacting with a relational database in a test:

1. wrap the whole test in a SQL transaction and rollback at the end of it
2. spin up a brand-new logical database for each integration test.

The first is clever and will generally be faster: rolling back a SQL transaction
takes less time than spinning up a new logical database. It works quite well
when writing unit tests for your queries but it is tricky to pull off in an
integration test like ours: our application will borrow a PgConnection from a
PgPool and we have no way to “capture” that connection in a SQL transaction
context. Which leads us to the second option: potentially slower, yet much
easier to implement.

How? Before each test run, we want to:

1. create a new logical database with a unique name;
2. run database migrations on it.

The best place to do this is spawn_app, before launching our actix-web test
application (see. `tests/health_check.rs`)

`configuration.database.connection_string()` uses the database_name specified in
our configura­tion.yaml file - the same for all tests. Let’s randomise it with
`uuid`.

`cargo test` will fail: there is no database ready to accept connections using
the name we generated. We need to create it! In order to issue a `CREATE
DATABASE` command we need to connect to the Postgres instance, which implies
connecting to a database that already exists. We’ll use the postgres database
for this purpose, the one that comes by default with a Postgres installation.
It’s often referred to as the “maintenance database” for this reason

`sqlx::migrate!` is the same macro used by `sqlx-cli` when executing `sqlx
migrate run` - no need to throw bash scripts into the mix to achieve the same
result

You might have noticed that we do not perform any clean-up step at the end of
our tests - the logical databases we create are not being deleted. This is
intentional: we could add a clean-up step, but our Postgres instance is used
only for test purposes and it’s easy enough to restart it if, after hundreds of
test runs, performance starts to suffer due to the number of lingering (almost
empty) databases.

## Chapter 4: Telemetry

> **Observability** is about being able to ask arbitrary questions about your
> environment without — and this is the key part — having to know ahead of time
> what you wanted to ask.

## Chapter 5: Going Live

## Chapter 6: Reject Invalid Subscribers \#1

## Chapter 7: Reject Invalid Subscribers \#2

## Chapter 8: Error Handling

## Chapter 9: Naive Newsletter Delivery

## Chapter 10: Securing Our API

## Chapter 11: Fault-tolerant Workflows

```

```
