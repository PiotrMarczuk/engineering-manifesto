# ============================================================================
# Engineering Manifesto — CLI Tooling
#
# ADR lifecycle  → managed by adr-tools (https://github.com/npryce/adr-tools)
#                  Install: brew install adr-tools
#                  Usage:   adr new "adopt postgresql"
#                           adr list
#                           adr link 5 "Supersedes" 2
#
# RFC lifecycle  → managed here (no external tool warranted — it's just a
#                  dated file from a template followed by a Pull Request)
#
# Repo-independent: uses relative paths, standard POSIX tools only.
# Usage: make help
# ============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Directories (override via env if your repo uses different paths)
RFC_DIR   ?= docs/rfc
ARCH_DIR  ?= docs/architecture
ADR_DIR   ?= docs/adr
AI_DIR    ?= ai

# Date
TODAY := $(shell date +%Y-%m-%d)

# Slug helper (lowercase, hyphens)
slug = $(shell echo "$(1)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# ============================================================================
# RFC Commands
# ============================================================================

.PHONY: new-rfc
new-rfc: ## Create a new RFC — Usage: make new-rfc title="my proposal title"
ifndef title
	$(error Usage: make new-rfc title="my proposal title")
endif
	@mkdir -p $(RFC_DIR)
	@SLUG=$(call slug,$(title)); \
	FILE="$(RFC_DIR)/$(TODAY)-$${SLUG}.md"; \
	if [ -f "$$FILE" ]; then echo "ERROR: $$FILE already exists"; exit 1; fi; \
	SAFE_TITLE=$$(printf '%s\n' "$(title)" | sed 's/[|&\\]/\\&/g'); \
	sed -e "s|\[Proposal Title\]|$$SAFE_TITLE|" \
	    -e "s|YYYY-MM-DD|$(TODAY)|" \
	    "$(RFC_DIR)/0000-template.md" > "$$FILE"; \
	echo "✅ Created: $$FILE"; \
	echo "   Next: edit the file, then open a Pull Request for review."

.PHONY: list-rfc
list-rfc: ## List all RFCs with status
	@echo ""; \
	echo "📋 RFCs ($(RFC_DIR))"; \
	echo "────────────────────────────────────────────────────────"; \
	for f in $(RFC_DIR)/[0-9]*.md; do \
		[ "$$f" = "$(RFC_DIR)/0000-template.md" ] && continue; \
		[ -f "$$f" ] || continue; \
		STATUS=$$(grep -m1 'Status:' "$$f" | sed 's/.*`\(.*\)`.*/\1/' | head -1); \
		echo "  $$STATUS	$$f"; \
	done; \
	echo ""

# ============================================================================
# Documentation Quality
# ============================================================================

.PHONY: lint-docs
lint-docs: ## Validate doc naming conventions, required sections, and broken internal links
	@ERRORS=0; \
	echo ""; \
	echo "🔍 Linting documentation..."; \
	echo "────────────────────────────────────────────────────────"; \
	echo ""; \
	echo "[ADRs — managed by adr-tools]"; \
	for f in $(ADR_DIR)/[0-9]*.md; do \
		[ -f "$$f" ] || continue; \
		if ! echo "$$f" | grep -qE '/[0-9]+-[a-z0-9-]+\.md$$'; then \
			echo "  ❌ Bad naming: $$f (expected NNN-lowercase-slug.md per adr-tools convention)"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
		for section in "## Status" "## Context" "## Decision" "## Consequences"; do \
			if ! grep -q "$$section" "$$f"; then \
				echo "  ❌ Missing section '$$section' in $$f"; \
				ERRORS=$$((ERRORS+1)); \
			fi; \
		done; \
	done; \
	echo ""; \
	echo "[RFCs]"; \
	for f in $(RFC_DIR)/[0-9]*.md; do \
		[ "$$f" = "$(RFC_DIR)/0000-template.md" ] && continue; \
		[ -f "$$f" ] || continue; \
		if ! echo "$$f" | grep -qE '/[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md$$'; then \
			echo "  ❌ Bad naming: $$f (expected [YYYY-MM-DD]-slug.md)"; \
			ERRORS=$$((ERRORS+1)); \
		fi; \
		for section in "## Problem Statement" "## Proposed Solution" "## Alternatives Considered"; do \
			if ! grep -q "$$section" "$$f"; then \
				echo "  ❌ Missing section '$$section' in $$f"; \
				ERRORS=$$((ERRORS+1)); \
			fi; \
		done; \
	done; \
	echo ""; \
	echo "[Internal Links]"; \
	for f in $$(find docs ai -name '*.md' 2>/dev/null); do \
		while read -r link; do \
			RESOLVED="$$(dirname $$f)/$$link"; \
			if [ ! -f "$$RESOLVED" ] && [ ! -f "$$link" ]; then \
				echo "  ❌ Broken link in $$f → $$link"; \
				ERRORS=$$((ERRORS+1)); \
			fi; \
		done < <(grep -oE '\]\(\.?/?[^)]+\.md[^)]*\)' "$$f" 2>/dev/null | sed 's|](\./|(|;s|](|(|' | tr -d '()' | sed 's/#.*//'); \
	done; \
	echo ""; \
	if [ $$ERRORS -gt 0 ]; then \
		echo "💥 $$ERRORS issue(s) found."; exit 1; \
	else \
		echo "✅ All checks passed."; \
	fi

# ============================================================================
# Scaffolding
# ============================================================================

.PHONY: init
init: ## Bootstrap all required directories and templates (safe to re-run)
	@command -v adr >/dev/null 2>&1 || { echo "⚠️  adr-tools not found. Install: brew install adr-tools"; }
	@mkdir -p $(RFC_DIR) $(ARCH_DIR) $(AI_DIR) $(AI_DIR)/prompts docs/diagrams src tests
	@if command -v adr >/dev/null 2>&1 && [ ! -d "$(ADR_DIR)" ]; then \
		adr init $(ADR_DIR); \
		echo "✅ ADR directory initialized via adr-tools."; \
	else \
		mkdir -p $(ADR_DIR); \
	fi
	@echo "✅ Directory structure initialized."
	@echo "   RFC template: $(RFC_DIR)/0000-template.md"
	@echo "   ADR workflow: adr new \"your decision title\""

# ============================================================================
# Help
# ============================================================================

.PHONY: help
help: ## Show this help
	@echo ""; \
	echo "Engineering Manifesto — CLI Tooling"; \
	echo "════════════════════════════════════════════════════════"; \
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'; \
	echo ""
