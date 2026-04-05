# claw-code-free — development and build automation
#
# Usage: make <target>
#   make          Print this help
#   make install  Install all toolchain/dependency prerequisites
#   make build    Build the release binary
#   make test     Run all tests (Rust + Python)
#   make lint     Run linters without tests
#   make fmt      Auto-format code
#   make verify   Format-check + lint + test (full CI gate)
#   make run      Run the CLI in interactive mode (requires ANTHROPIC_API_KEY)
#   make help     Same as default target

.DEFAULT_GOAL := help

# ── Paths ─────────────────────────────────────────────────────────────────────
RUST_DIR   := rust
BINARY     := $(RUST_DIR)/target/release/claw
PYTHON     := python3

# ── Colours ───────────────────────────────────────────────────────────────────
BOLD  := \033[1m
RESET := \033[0m
GREEN := \033[32m
CYAN  := \033[36m

# ─────────────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Print this help message
	@echo ""
	@echo "  $(BOLD)claw-code-free$(RESET) — available targets"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-14s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ── Install ───────────────────────────────────────────────────────────────────

.PHONY: install
install: install-rust install-python ## Install all prerequisites

.PHONY: install-rust
install-rust: ## Install/update the Rust stable toolchain
	@echo "$(BOLD)Installing Rust stable toolchain…$(RESET)"
	rustup toolchain install stable
	rustup component add rustfmt clippy
	@echo "$(GREEN)Rust toolchain ready.$(RESET)"

.PHONY: install-python
install-python: ## Check Python version (no extra packages required)
	@echo "$(BOLD)Checking Python…$(RESET)"
	@$(PYTHON) --version
	@echo "$(GREEN)Python ready (no extra packages required).$(RESET)"

# ── Build ─────────────────────────────────────────────────────────────────────

.PHONY: build
build: ## Build the release binary  (output: rust/target/release/claw)
	@echo "$(BOLD)Building release binary…$(RESET)"
	cd $(RUST_DIR) && cargo build --release --bin claw
	@echo "$(GREEN)Binary: $(BINARY)$(RESET)"

.PHONY: build-dev
build-dev: ## Build a debug binary for fast iteration
	@echo "$(BOLD)Building debug binary…$(RESET)"
	cd $(RUST_DIR) && cargo build --bin claw

# ── Test ──────────────────────────────────────────────────────────────────────

.PHONY: test
test: test-rust test-python ## Run all tests

.PHONY: test-rust
test-rust: ## Run Rust tests
	@echo "$(BOLD)Running Rust tests…$(RESET)"
	cd $(RUST_DIR) && cargo test --workspace
	@echo "$(GREEN)Rust tests passed.$(RESET)"

.PHONY: test-python
test-python: ## Run Python tests
	@echo "$(BOLD)Running Python tests…$(RESET)"
	$(PYTHON) -m unittest discover -s tests -v
	@echo "$(GREEN)Python tests passed.$(RESET)"

# ── Lint / format ─────────────────────────────────────────────────────────────

.PHONY: fmt
fmt: ## Auto-format Rust code
	cd $(RUST_DIR) && cargo fmt --all

.PHONY: lint
lint: ## Run Clippy (deny warnings) and check formatting
	cd $(RUST_DIR) && cargo fmt --all -- --check
	cd $(RUST_DIR) && cargo clippy --workspace --all-targets -- -D warnings

# ── Verify (full CI gate) ─────────────────────────────────────────────────────

.PHONY: verify
verify: lint test ## Run the full CI gate: lint + all tests
	@echo "$(GREEN)All checks passed.$(RESET)"

# ── Run ───────────────────────────────────────────────────────────────────────

.PHONY: run
run: ## Run the interactive CLI  (requires ANTHROPIC_API_KEY or prior `make login`)
	@echo "$(BOLD)Starting Claw Code CLI…$(RESET)"
	@echo "  Tip: run 'make build' first if the binary is stale."
	$(BINARY)

.PHONY: login
login: ## Start the OAuth login flow  (stores credentials in CLAUDE_CONFIG_HOME)
	$(BINARY) login

# ── Python workspace utilities ────────────────────────────────────────────────

.PHONY: summary
summary: ## Render the Python porting workspace summary
	$(PYTHON) -m src.main summary

.PHONY: manifest
manifest: ## Print the current Python workspace manifest
	$(PYTHON) -m src.main manifest

# ── Health / verification ─────────────────────────────────────────────────────

.PHONY: health
health: ## Minimum verification: confirm the binary and Python workspace are functional
	@echo "$(BOLD)--- Rust binary health check ---$(RESET)"
	$(BINARY) --help
	@echo ""
	@echo "$(BOLD)--- Python workspace health check ---$(RESET)"
	$(PYTHON) -m src.main summary
	@echo "$(GREEN)Health check passed.$(RESET)"

# ── Utilities ─────────────────────────────────────────────────────────────────

.PHONY: clean
clean: ## Remove build artefacts
	cd $(RUST_DIR) && cargo clean
