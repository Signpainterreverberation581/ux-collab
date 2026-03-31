#!/usr/bin/env bash
# setup.sh — one-command setup for ux-collab v2.2.0
# Usage: bash scripts/setup.sh
# 
# Installs: agent-browser, ImageMagick, creates project config
# Guides: Figma MCP setup (optional)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

color() { printf '\033[%sm' "$1"; }
reset() { printf '\033[0m'; }
section() { echo ""; color "1;34"; echo "▶ $1"; reset; }
ok() { color "32"; echo "  ✔ $1"; reset; }
info() { color "33"; echo "  ⓘ $1"; reset; }
warn() { color "35"; echo "  ⚠ $1"; reset; }

# ── Step 1: agent-browser ────────────────────────────────────────────────────
section "Installing agent-browser (Primary Browser Tool)"

if command -v agent-browser &>/dev/null; then
  ok "agent-browser $(agent-browser --version | head -1)"
else
  info "Installing agent-browser..."
  
  if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
    brew install agent-browser
  else
    npm install -g agent-browser
  fi
  
  ok "agent-browser installed"
  info "Downloading Chrome (first run, ~200MB)..."
  agent-browser install
  ok "Chrome downloaded"
fi

# ── Step 2: ImageMagick ───────────────────────────────────────────────────────
section "Installing ImageMagick (Screenshot Optimization)"

if command -v convert &>/dev/null && command -v identify &>/dev/null; then
  ok "ImageMagick installed"
else
  info "Installing ImageMagick..."
  
  if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
    brew install imagemagick
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y imagemagick
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y ImageMagick
  else
    warn "Cannot auto-install. Install ImageMagick manually."
  fi
  
  ok "ImageMagick installed"
fi

# ── Step 3: Project config ────────────────────────────────────────────────────
section "Project Configuration"

if [[ -f ".ux-collab.md" ]]; then
  ok ".ux-collab.md exists"
else
  info "Creating .ux-collab.md..."
  cat > .ux-collab.md << 'EOF'
# UX Collab — Project Config

## Settings
defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

## Target Files (example paths - update for your project)
targetFiles:
  tokens: app/globals.css
  components: app/_components/
  
## Brand Tokens (example - update with your design system)
brandTokens:
  colors:
    primary: --color-primary
    secondary: --color-secondary
  spacing:
    sm: --space-4
    md: --space-8
    lg: --space-16

## Surface Map
surfaces:
  - name: Homepage
    route: /
  - name: Dashboard
    route: /dashboard

## Open Design Decisions
EOF
  ok "Created .ux-collab.md"
fi

# ── Step 4: CLAUDE.md (Optional) ─────────────────────────────────────────────
if [[ ! -f "CLAUDE.md" ]]; then
  info "Creating CLAUDE.md (project governance)..."
  cp "${PACKAGE_ROOT}/CLAUDE.md" ./CLAUDE.md 2>/dev/null || true
fi

# ── Step 5: Optional MCP Setup ────────────────────────────────────────────────
section "Optional MCP Tools"

echo ""
echo "  Figma MCP (for design system integration):"
echo "    Add to .mcp.json:"
echo '    { "mcpServers": { "figma": { "command": "npx", "args": ["-y","@figma/mcp"], "env": { "FIGMA_API_KEY": "YOUR_KEY" } } } }'
echo ""
echo "  Playwright MCP (backup browser tool):"
echo "    Add to .mcp.json:"
echo '    { "mcpServers": { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] } } }'
echo ""

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  Setup Complete ✓                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
ok "agent-browser — Primary browser tool"
ok "ImageMagick — Screenshot optimization"
ok ".ux-collab.md — Project config"
echo ""
echo "Quick Start:"
echo "  1. Edit .ux-collab.md with your dev server URL"
echo "  2. Start your dev server"
echo "  3. Tell your agent: 'Let's work on the UI'"
echo ""
echo "See: https://github.com/kylebrodeur/ux-collab"
