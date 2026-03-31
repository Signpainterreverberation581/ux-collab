#!/usr/bin/env bash
# check.sh — verify ux-collab dependencies (v2.2.0)
# Usage: bash scripts/check.sh

set -euo pipefail

PASS=0; FAIL=0; WARN=0
ok() { echo "  ✔ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✘ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠ $1"; WARN=$((WARN+1)); }
section() { echo ""; echo "── $1"; }

echo "═══ ux-collab check ═══"

# ── Required: agent-browser ────────────────────────────────────────────────────
section "Primary Browser (agent-browser)"

if command -v agent-browser &>/dev/null; then
  ok "agent-browser $(agent-browser --version 2>/dev/null | head -1)"
else
  fail "agent-browser not found"
  echo "    Install: brew install agent-browser  (macOS)"
  echo "             npm i -g agent-browser      (any)"
fi

# ── Required: ImageMagick ─────────────────────────────────────────────────────
section "Screenshot Optimization (ImageMagick)"

if command -v convert &>/dev/null && command -v identify &>/dev/null; then
  ok "convert + identify"
else
  fail "ImageMagick not found"
  echo "    Install: brew install imagemagick    (macOS)"
  echo "             sudo apt install imagemagick (Ubuntu/Debian)"
fi

# ── Optional: Playwright MCP ─────────────────────────────────────────────────
section "Alternative Browser (Playwright MCP) — Optional"

PLAYWRIGHT_FOUND=false
for MCP_FILE in ".mcp.json" "${HOME}/.mcp.json"; do
  [[ -f "$MCP_FILE" ]] && grep -q "playwright" "$MCP_FILE" 2>/dev/null && PLAYWRIGHT_FOUND=true && break
done

if [[ "$PLAYWRIGHT_FOUND" == true ]]; then
  ok "Playwright MCP configured"
else
  warn "Playwright MCP not configured (optional - agent-browser is primary)"
fi

# ── Optional: Figma MCP ──────────────────────────────────────────────────────
section "Design System (Figma MCP) — Optional"

FIGMA_FOUND=false
for MCP_FILE in ".mcp.json" "${HOME}/.mcp.json"; do
  [[ -f "$MCP_FILE" ]] && grep -q "figma" "$MCP_FILE" 2>/dev/null && FIGMA_FOUND=true && break
done

if [[ "$FIGMA_FOUND" == true ]]; then
  ok "Figma MCP configured"
else
  warn "Figma MCP not configured (optional)"
  echo "    Add to .mcp.json for design system integration"
fi

# ── Project Config ───────────────────────────────────────────────────────────
section "Project Config"

if [[ -f ".ux-collab.md" ]]; then
  ok ".ux-collab.md present"
else
  warn ".ux-collab.md not found (run: npx ux-collab init)"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
printf "  ✔ Passed:   %d\n" "$PASS"
printf "  ⚠ Warnings: %d\n" "$WARN"
printf "  ✘ Failed:   %d\n" "$FAIL"
echo "═══════════════════════════════════════════"

if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "Run: bash scripts/setup.sh"
  exit 1
else
  echo ""
  echo "Ready! Try: 'Let's work on the UI' or 'Take a screenshot'"
  exit 0
fi
