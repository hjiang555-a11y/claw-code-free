# Deployment Preparation Guide

This document covers how to install, build, run, and verify **claw-code-free** on a
local workstation, WSL 2, or a bare Ubuntu server in preparation for deployment
testing. It is intended for developers who are bringing up the project for the first
time.

---

## Table of Contents

1. [Runtime requirements](#1-runtime-requirements)
2. [Get the code](#2-get-the-code)
3. [Environment variables](#3-environment-variables)
4. [Install dependencies](#4-install-dependencies)
5. [Build the Rust CLI](#5-build-the-rust-cli)
6. [Run the Python workspace](#6-run-the-python-workspace)
7. [Run tests](#7-run-tests)
8. [Health check and verification](#8-health-check-and-verification)
9. [Common troubleshooting](#9-common-troubleshooting)
10. [Recommended deployment test order](#10-recommended-deployment-test-order)

---

## 1. Runtime requirements

| Requirement | Minimum version | Notes |
|---|---|---|
| Rust | stable (1.70+) | Install via `rustup` |
| Python | 3.11+ | 3.12 works fine |
| git | any recent | needed for workspace detection |

No additional system packages or databases are required for local development.
The Rust build system (`cargo`) downloads all Rust dependencies automatically.
The Python workspace has no third-party package dependencies beyond the standard library.

---

## 2. Get the code

```bash
git clone https://github.com/hjiang555-a11y/claw-code-free.git
cd claw-code-free
```

---

## 3. Environment variables

Copy the example file and fill in the values you need:

```bash
cp .env.example .env
```

Open `.env` in your editor. The key variables are:

| Variable | Required | Purpose |
|---|---|---|
| `ANTHROPIC_API_KEY` | Yes — for API calls | Your Anthropic API key |
| `ANTHROPIC_AUTH_TOKEN` | Alternative to above | OAuth bearer token (after `claw login`) |
| `ANTHROPIC_BASE_URL` | No | Override API endpoint (proxy / staging) |
| `CLAUDE_CONFIG_HOME` | No | Custom directory for credentials and config |
| `CLAWD_WORKSPACE_ROOT` | No | Override sandbox root detection |
| `CLAWD_TRUST_PROJECT_EXTENSIONS` | No | Set `1` to allow repo-checked-in hooks/MCP |

See `.env.example` for the full list and descriptions of all variables.

> **Note:** The Python workspace (`src/`) is a metadata/stub layer and does not
> make live API calls. You only need `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN`
> when running the Rust CLI (`claw`) in interactive or prompt mode.

---

## 4. Install dependencies

### Rust toolchain

```bash
# Install rustup (skip if already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# Install or update the stable toolchain
rustup toolchain install stable
rustup component add rustfmt clippy
```

Or with Make:

```bash
make install-rust
```

### Python

Python 3.11+ is the only requirement; no third-party packages need to be installed:

```bash
python3 --version   # should report 3.11 or later
```

---

## 5. Build the Rust CLI

### Debug build (fast, for development)

```bash
cd rust
cargo build --bin claw
# binary: rust/target/debug/claw
```

### Release build (optimised, for deployment testing)

```bash
cd rust
cargo build --release --bin claw
# binary: rust/target/release/claw
```

Or from the repo root with Make:

```bash
make build
```

### Verify the binary

```bash
./rust/target/release/claw --help
```

Expected output: the CLI help message listing `--model`, `--permission-mode`, and
subcommands (`login`, `logout`, `prompt`, `bootstrap-plan`, `dump-manifests`).

### Optional: add the binary to your PATH

```bash
# Temporary (current shell session only)
export PATH="$PWD/rust/target/release:$PATH"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/claw-code-free/rust/target/release:$PATH"' >> ~/.bashrc
```

---

## 6. Run the Python workspace

The Python `src/` tree provides metadata inspection, parity auditing, and workspace
summary utilities. It does not perform live API calls.

```bash
# From the repo root:

# Render a workspace summary
python3 -m src.main summary

# Print the workspace manifest
python3 -m src.main manifest

# List subsystems
python3 -m src.main subsystems --limit 16
```

---

## 7. Run tests

### Both test suites (recommended before any deployment)

```bash
make test
```

### Rust tests only

```bash
cd rust && cargo test --workspace
```

### Python tests only

```bash
python3 -m unittest discover -s tests -v
```

All tests should pass without any environment variables set.

---

## 8. Health check and verification

### Minimum verification command (both components)

```bash
make health
```

This runs `claw --help` (Rust) and `python3 -m src.main summary` (Python).
Both should exit with code `0` and produce human-readable output.

### Manual health check steps

```bash
# 1. Rust binary
./rust/target/release/claw --help
echo "Exit code: $?"   # expect 0

# 2. Python workspace
python3 -m src.main summary
echo "Exit code: $?"   # expect 0

# 3. Full test suite (optional — takes longer)
make test
```

### Interactive login and prompt (requires API key)

```bash
# Log in via OAuth (stores token in ~/.claude)
./rust/target/release/claw login

# Or export your API key and run a one-shot prompt
ANTHROPIC_API_KEY=your-key ./rust/target/release/claw prompt "Hello"
```

---

## 9. Common troubleshooting

### `cargo: command not found`

Rust is not installed or `~/.cargo/bin` is not on `PATH`.

```bash
source "$HOME/.cargo/env"
# or add the following to ~/.bashrc:
# export PATH="$HOME/.cargo/bin:$PATH"
```

### Build fails: `error[E0XXX]` or linker errors

```bash
rustup update stable            # update to latest stable
rustup component add rustfmt clippy
cd rust && cargo clean && cargo build --release --bin claw
```

On Ubuntu, you may also need the `build-essential` package:

```bash
sudo apt-get install -y build-essential
```

### `claw --help` exits immediately with no output

Check the binary architecture and permissions:

```bash
file rust/target/release/claw
chmod +x rust/target/release/claw
```

On WSL, make sure the Windows filesystem is not mounted with `noexec`. Run the binary
from a Linux filesystem path (e.g. `~/` or `/tmp/`), not from `/mnt/c/…`.

### Python test failures

```bash
python3 --version   # must be 3.11+
# Run a single test to see the full traceback:
python3 -m unittest tests.test_porting_workspace.PortingWorkspaceTests.test_cli_summary_runs -v
```

### `ANTHROPIC_API_KEY is not set` at runtime

Export the variable before running the CLI:

```bash
export ANTHROPIC_API_KEY=your-key-here
./rust/target/release/claw prompt "Hello"
```

Or use the OAuth flow instead:

```bash
./rust/target/release/claw login
```

### Port conflicts

The Rust CLI does not listen on a fixed port by default. The OAuth callback uses an
ephemeral port chosen by the OS. If you see bind errors, check for other processes:

```bash
ss -tlnp | grep <port>
```

### Missing environment variables

Run the workspace setup report to see which subsystems have detected issues:

```bash
python3 -m src.main setup-report
```

### Where to find logs

- **Rust CLI:** errors are printed to `stderr`. Redirect with `2>claw-error.log`.
- **Python workspace:** tracebacks are printed to `stderr`.
- **Session transcripts:** stored in `.port_sessions/` (Python) and
  `~/.claude/sessions/` (Rust, after login).

---

## 10. Recommended deployment test order

Follow this order to catch environment and dependency issues early.

### Step 1 — WSL 2 (Windows Subsystem for Linux)

WSL is the lowest-risk first target because you can easily reset the environment.

```bash
# 1. Open a WSL terminal (Ubuntu 22.04 or 24.04 recommended)
# 2. Install prerequisites
sudo apt-get update && sudo apt-get install -y build-essential git curl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# 3. Clone and build
git clone https://github.com/hjiang555-a11y/claw-code-free.git
cd claw-code-free
make install
make build

# 4. Health check
make health

# 5. Run tests
make test
```

Known WSL-specific considerations:

- Run all commands from a Linux filesystem path (`~/`, `/tmp/`), not from `/mnt/c/`.
- If `cargo` is slow, disable Windows Defender real-time scanning on the WSL filesystem
  or move the repo to `/home/`.
- WSL 2 clock skew can cause TLS errors; run `sudo hwclock -s` if you see certificate
  validation failures.

### Step 2 — Ubuntu server (bare-metal or VM)

Once WSL tests pass, repeat on a headless Ubuntu 22.04 or 24.04 server:

```bash
# 1. Update and install prerequisites
sudo apt-get update && sudo apt-get install -y build-essential git curl

# 2. Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# 3. Clone and build
git clone https://github.com/hjiang555-a11y/claw-code-free.git
cd claw-code-free
make install
make build

# 4. Health check
make health

# 5. Run tests
make test

# 6. Interactive session (requires API key or prior OAuth login)
export ANTHROPIC_API_KEY=your-key-here
./rust/target/release/claw prompt "Summarize this repository"
```

> **Headless note:** `claw login` opens a browser for OAuth. On a headless server,
> use `ANTHROPIC_API_KEY` instead, or tunnel the OAuth callback through SSH:
> `ssh -L 0:localhost:0 user@server` and copy the callback URL to a local browser.
