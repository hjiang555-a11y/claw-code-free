# Rewriting Project Claw Code

<p align="center">
  <strong>⭐ The fastest repo in history to surpass 50K stars, reaching the milestone in just 2 hours after publication ⭐</strong>
</p>

<p align="center">
  <a href="https://star-history.com/#instructkr/claw-code&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=instructkr/claw-code&type=Date&theme=dark" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=instructkr/claw-code&type=Date" />
      <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=instructkr/claw-code&type=Date" width="600" />
    </picture>
  </a>
</p>

<p align="center">
  <img src="assets/clawd-hero.jpeg" alt="Claw" width="300" />
</p>

<p align="center">
  <strong>Better Harness Tools, not merely storing the archive of leaked Claude Code</strong>
</p>

<p align="center">
  <a href="https://github.com/sponsors/instructkr"><img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-pink?logo=github&style=for-the-badge" alt="Sponsor on GitHub" /></a>
</p>

> [!IMPORTANT]
> **Rust port is now in progress** on the [`dev/rust`](https://github.com/instructkr/claw-code/tree/dev/rust) branch and is expected to be merged into main today. The Rust implementation aims to deliver a faster, memory-safe harness runtime. Stay tuned — this will be the definitive version of the project.

> If you find this work useful, consider [sponsoring @instructkr on GitHub](https://github.com/sponsors/instructkr) to support continued open-source harness engineering research.

---

## Backstory

At 4 AM on March 31, 2026, I woke up to my phone blowing up with notifications. The Claude Code source had been exposed, and the entire dev community was in a frenzy. My girlfriend in Korea was genuinely worried I might face legal action from Anthropic just for having the code on my machine — so I did what any engineer would do under pressure: I sat down, ported the core features to Python from scratch, and pushed it before the sun came up.

The whole thing was orchestrated end-to-end using [oh-my-codex (OmX)](https://github.com/Yeachan-Heo/oh-my-codex) by [@bellman_ych](https://x.com/bellman_ych) — a workflow layer built on top of OpenAI's Codex ([@OpenAIDevs](https://x.com/OpenAIDevs)). I used `$team` mode for parallel code review and `$ralph` mode for persistent execution loops with architect-level verification. The entire porting session — from reading the original harness structure to producing a working Python tree with tests — was driven through OmX orchestration.

The result is a clean-room Python rewrite that captures the architectural patterns of Claude Code's agent harness without copying any proprietary source. I'm now actively collaborating with [@bellman_ych](https://x.com/bellman_ych) — the creator of OmX himself — to push this further. The basic Python foundation is already in place and functional, but we're just getting started. **Stay tuned — a much more capable version is on the way.**

https://github.com/instructkr/claw-code

![Tweet screenshot](assets/tweet-screenshot.png)

## The Creators Featured in Wall Street Journal For Avid Claude Code Fans

I've been deeply interested in **harness engineering** — studying how agent systems wire tools, orchestrate tasks, and manage runtime context. This isn't a sudden thing. The Wall Street Journal featured my work earlier this month, documenting how I've been one of the most active power users exploring these systems:

> AI startup worker Sigrid Jin, who attended the Seoul dinner, single-handedly used 25 billion of Claude Code tokens last year. At the time, usage limits were looser, allowing early enthusiasts to reach tens of billions of tokens at a very low cost.
>
> Despite his countless hours with Claude Code, Jin isn't faithful to any one AI lab. The tools available have different strengths and weaknesses, he said. Codex is better at reasoning, while Claude Code generates cleaner, more shareable code.
>
> Jin flew to San Francisco in February for Claude Code's first birthday party, where attendees waited in line to compare notes with Cherny. The crowd included a practicing cardiologist from Belgium who had built an app to help patients navigate care, and a California lawyer who made a tool for automating building permit approvals using Claude Code.
>
> "It was basically like a sharing party," Jin said. "There were lawyers, there were doctors, there were dentists. They did not have software engineering backgrounds."
>
> — *The Wall Street Journal*, March 21, 2026, [*"The Trillion Dollar Race to Automate Our Entire Lives"*](https://lnkd.in/gs9td3qd)

![WSJ Feature](assets/wsj-feature.png)

---

## Porting Status

The repository currently has two distinct implementation surfaces:

- `rust/` contains the active CLI/runtime implementation
- `src/` contains the Python mirrored metadata/stub workspace
- `tests/` verifies the Python metadata workspace
- the exposed snapshot is no longer part of the tracked repository state

The Python workspace is useful for parity auditing, inventory browsing, and porting analysis, but it is not a full runtime-equivalent replacement. Real tool execution, Anthropic API integration, permissions, hooks, sandboxing, and MCP runtime plumbing live under `rust/`.

## Why this rewrite exists

I originally studied the exposed codebase to understand its harness, tool wiring, and agent workflow. After spending more time with the legal and ethical questions—and after reading the essay linked below—I did not want the exposed snapshot itself to remain the main tracked source tree.

This repository now focuses on Python porting work instead.

## Requirements

| Requirement | Minimum | Notes |
|---|---|---|
| Rust | stable (1.70+) | Install via `rustup` — see [rustup.rs](https://rustup.rs) |
| Python | 3.11+ | No third-party packages required |
| git | any recent | needed for workspace detection |

## Install

```bash
# 1. Clone
git clone https://github.com/hjiang555-a11y/claw-code-free.git
cd claw-code-free

# 2. Install Rust stable toolchain (skip if already installed)
rustup toolchain install stable
rustup component add rustfmt clippy

# 3. Copy environment variable template and fill in your values
cp .env.example .env
```

See [`.env.example`](.env.example) for the full list of supported variables and [docs/deployment-prep.md](docs/deployment-prep.md) for a step-by-step deployment guide.

## Repository Layout

```text
.
├── src/                                # Python porting workspace
│   ├── __init__.py
│   ├── commands.py
│   ├── main.py
│   ├── models.py
│   ├── port_manifest.py
│   ├── query_engine.py
│   ├── task.py
│   └── tools.py
├── tests/                              # Python verification
├── assets/omx/                         # OmX workflow screenshots
├── 2026-03-09-is-legal-the-same-as-legitimate-ai-reimplementation-and-the-erosion-of-copyleft.md
└── README.md
```

## Python Workspace Overview

The new Python `src/` tree currently provides:

- **`port_manifest.py`** — summarizes the current Python workspace structure
- **`models.py`** — dataclasses for subsystems, modules, and backlog state
- **`commands.py`** — Python-side command port metadata
- **`tools.py`** — Python-side tool port metadata
- **`query_engine.py`** — renders a Python porting summary from the active workspace
- **`main.py`** — a CLI entrypoint for manifest and summary output

The Python command/tool execution shims are metadata-only stubs: they report mirrored archive entries for inspection, but they do not perform live tool or agent execution.

## Quickstart

### Build the Rust CLI

```bash
cd rust && cargo build --release --bin claw
# binary: rust/target/release/claw
```

Verify it runs:

```bash
./rust/target/release/claw --help
```

Run an interactive session (requires `ANTHROPIC_API_KEY` or prior `claw login`):

```bash
export ANTHROPIC_API_KEY=your-key-here
./rust/target/release/claw
```

### Python workspace

Render the Python porting summary:

```bash
python3 -m src.main summary
```

Print the current Python workspace manifest:

```bash
python3 -m src.main manifest
```

List the current Python modules:

```bash
python3 -m src.main subsystems --limit 16
```

Run verification:

```bash
python3 -m unittest discover -s tests -v
```

## Run / Build / Test reference

A `Makefile` is provided for convenience:

| Command | What it does |
|---|---|
| `make install` | Install Rust toolchain + check Python |
| `make build` | Build the release binary (`rust/target/release/claw`) |
| `make build-dev` | Build a debug binary (faster, larger) |
| `make test` | Run Rust + Python tests |
| `make lint` | Run Clippy and format-check |
| `make fmt` | Auto-format Rust code |
| `make verify` | Full CI gate: lint + all tests |
| `make health` | Minimum verification of both components |
| `make run` | Start the interactive CLI |
| `make login` | OAuth login flow |

Run `make` (or `make help`) to see the full target list.

## Security defaults

- The Rust CLI now defaults to `prompt` permission mode instead of unrestricted execution.
- Project-checked-in `hooks` and `mcpServers` settings are ignored by default to reduce supply-chain risk from untrusted repositories.
- To explicitly trust repository-provided hook/MCP extensions for a workspace, set `CLAWD_TRUST_PROJECT_EXTENSIONS=1`.
- File editing, notebook editing, and attachment resolution are limited to the active workspace root.

Run the parity audit against the local ignored archive (when present):

```bash
python3 -m src.main parity-audit
```

Inspect mirrored command/tool inventories:

```bash
python3 -m src.main commands --limit 10
python3 -m src.main tools --limit 10
```

## Current Parity Checkpoint

The port now mirrors the archived root-entry file surface, top-level subsystem names, and command/tool inventories much more closely than before. However, it is **not yet** a full runtime-equivalent replacement for the original TypeScript system; the Python tree still contains fewer executable runtime slices than the archived source.


## Built with `oh-my-codex`

The restructuring and documentation work on this repository was AI-assisted and orchestrated with Yeachan Heo's [oh-my-codex (OmX)](https://github.com/Yeachan-Heo/oh-my-codex), layered on top of Codex.

- **`$team` mode:** used for coordinated parallel review and architectural feedback
- **`$ralph` mode:** used for persistent execution, verification, and completion discipline
- **Codex-driven workflow:** used to turn the main `src/` tree into a Python-first porting workspace

### OmX workflow screenshots

![OmX workflow screenshot 1](assets/omx/omx-readme-review-1.png)

*Ralph/team orchestration view while the README and essay context were being reviewed in terminal panes.*

![OmX workflow screenshot 2](assets/omx/omx-readme-review-2.png)

*Split-pane review and verification flow during the final README wording pass.*

## Troubleshooting

### `cargo: command not found`
Rust is not on `PATH`. Run `source "$HOME/.cargo/env"` or add `~/.cargo/bin` to your shell profile.

### Build fails with linker errors (Ubuntu / WSL)
Install the C toolchain: `sudo apt-get install -y build-essential`

### `claw` binary won't execute on WSL
Run from a Linux filesystem path (`~/`, `/tmp/`), not `/mnt/c/…`. Windows-mounted filesystems can be mounted `noexec`.

### `ANTHROPIC_API_KEY is not set`
Export the variable before running, or use `claw login` for the OAuth flow:
```bash
export ANTHROPIC_API_KEY=your-key-here
```

### Checking for missing environment variables
```bash
python3 -m src.main setup-report
```

### Where are logs?
- **Rust CLI** — errors go to `stderr`. Redirect with `2>claw.log`.
- **Session transcripts** — stored in `.port_sessions/` (Python) and `~/.claude/sessions/` (Rust).

For a full troubleshooting guide and WSL / Ubuntu deployment steps, see [docs/deployment-prep.md](docs/deployment-prep.md).

## Community

<p align="center">
  <a href="https://instruct.kr/"><img src="assets/instructkr.png" alt="instructkr" width="400" /></a>
</p>

Join the [**instructkr Discord**](https://instruct.kr/) — the best Korean language model community. Come chat about LLMs, harness engineering, agent workflows, and everything in between.

[![Discord](https://img.shields.io/badge/Join%20Discord-instruct.kr-5865F2?logo=discord&style=for-the-badge)](https://instruct.kr/)

## Star History

See the chart at the top of this README.

## Ownership / Affiliation Disclaimer

- This repository does **not** claim ownership of the original Claude Code source material.
- This repository is **not affiliated with, endorsed by, or maintained by Anthropic**.
