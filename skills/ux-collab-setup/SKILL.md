---
name: ux-collab-setup
description: "Install and configure all ux-collab dependencies. Use when: setting up ux-collab for the first time, something isn't working, check.sh reports failures, agent-browser is missing, Playwright MCP is missing, ImageMagick is missing, or the user asks to 'set up ux-collab', 'fix the dependencies', or 'get ux-collab ready'."
compatibility: "Requires bash. ImageMagick auto-installed on macOS (brew) and Ubuntu/Debian (apt). agent-browser and Playwright MCP require manual steps guided by this skill."
license: MIT
metadata:
  author: kylebrodeur
  version: "1.1"
---

# UX Collab Setup Skill

Diagnose and fix missing ux-collab dependencies in one guided session.

## Step 1 — Run the check

Find the package root and run the check script:

```bash
# From the cloned repo / package directory:
npm run check      # or: pnpm run check
# or:
bash scripts/check.sh
```

Read the output carefully. Each line is either ✔ (pass), ⚠ (warning/optional), or ✘ (required — must fix).

## Step 2 — Auto-fix what can be automated

Run the setup script — it handles ImageMagick installation, agent-browser installation, and creates `.ux-collab.md` if missing:

```bash
# From the cloned repo / package directory:
npm run setup      # or: pnpm run setup
# or:
bash scripts/setup.sh
```

This will:
- Check if agent-browser is installed; if not, attempt to install via brew (macOS) or prompt for npm
- Install ImageMagick via `brew` (macOS) or `apt` (Ubuntu/Debian) if missing
- Make `optimize-screenshot.sh` executable
- Copy `optimize-screenshot.sh` to `~/.agents/skills/ux-collab/` if the skill is installed there
- Create a starter `.ux-collab.md` in the current directory if none exists
- Create a sample `agent-browser.json` config if desired
- Re-run `check.sh` at the end to confirm

## Step 3 — Install agent-browser (PRIMARY browser tool)

agent-browser is the recommended browser tool for ux-collab — it's faster, token-efficient, and requires no MCP setup.

### macOS (recommended via Homebrew — fastest)

```bash
brew install agent-browser
agent-browser install   # Downloads Chrome for Testing (first time only)
```

### Any Platform (via npm)

```bash
npm install -g agent-browser
agent-browser install   # Downloads Chrome for Testing (first time only)
```

### Verify Installation

```bash
agent-browser --version
# Should output: agent-browser x.x.x

agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

### Optional: Project Configuration

Create `agent-browser.json` in your project root for persistent defaults:

```json
{
  "headed": false,
  "screenshotDir": "./screenshots",
  "device": "iPhone 12"
}
```

See https://agent-browser.dev/configuration for all options.

## Step 4 — Fix Playwright MCP (Alternative / Optional)

Playwright MCP is **optional** — agent-browser covers all core ux-collab needs. Only install if you need:
- Full accessibility tree with semantic roles
- Complex multi-page interactions with state
- Specific viewport/device emulation
- MCP ecosystem already configured and working

### Claude Code (plugin system)

```bash
claude plugin install playwright@claude-plugins-official
```

Then restart Claude Code. Re-run `npm run check` (or `bash scripts/check.sh`) to confirm.

### If MCP servers start but hang or show pnpm path errors

This is a known issue on WSL and macOS when pnpm is managed via fnm or a non-standard path. Use the appropriate fixer:

```bash
npx @kylebrodeur/mcp-wsl-setup   # WSL (fixes fnm/pnpm paths in VS Code mcp.json)
npx @kylebrodeur/mcp-mac-setup   # macOS (fixes pnpm paths)
```

Re-run `npm run check` (or `bash scripts/check.sh`) after.

### Any harness (manual MCP server via `.mcp.json`)

Create or edit `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

Restart the agent session. Re-run `npm run check` (or `bash scripts/check.sh`) to confirm.

## Step 5 — Fix Lucid MCP (optional — skip if not needed)

Lucid MCP enables diagram creation in Step 3 of the ux-collab loop. Without it, the skill falls back to Markdown wireframes automatically — **this is not a blocker**.

To enable Lucid wireframes:

```bash
# Claude Code:
claude plugin install lucid@claude-plugins-official

# Or add to .mcp.json:
# "lucid": { "command": "npx", "args": ["@lucid/mcp@latest"] }
```

## Step 6 — Create project config (if warned)

If `check` warned that `.ux-collab.md` is missing, create one by copying the template from the repo or create manually:

```bash
# From the cloned repo:
cp .ux-collab.md.example .ux-collab.md
# Then edit `.ux-collab.md` to set:
# - `defaultUrl` — your dev server URL
# - `lucidShareEmail` — your Lucid account email
# - Brand tokens, target files, and surfaces
```

## Step 7 — Final verification

```bash
npm run check      # or: pnpm run check
# or:
bash scripts/check.sh
```

Expected output when fully ready:
```
✔ Passed:   6+
⚠ Warnings: 0–2  (Lucid and Playwright MCP are optional)
✘ Failed:   0
→ All required dependencies present. Ready to run ux-collab.
  Primary: agent-browser (installed)
  Alternative: Playwright MCP (optional)
```

If any ✘ remain, re-read the "Issues to fix" section printed by the script and follow the instructions there.

## Quick reference — what each dep does

| Dep | Required? | Why it's needed |
|-----|-----------|----------------|
| **agent-browser** | ✅ Yes | Primary browser tool. Takes screenshots, navigates, interacts. Rust CLI, no MCP needed. |
| image magick `convert` + `identify` | ✅ Yes | Resizes and compresses screenshots before attaching to chat |
| Playwright MCP (`mcp_playwright_*`) | ⚡ Optional | Alternative browser tool. Use when richer accessibility features needed. |
| Lucid MCP (`mcp_lucid_*`) | ⚡ Optional | Creates and exports wireframe diagrams — Markdown fallback available |
| `.ux-collab.md` | ⚡ Recommended | Per-project config: dev URL, brand tokens, file targets, open decisions |
| `agent-browser.json` | ⚡ Optional | Project-level agent-browser defaults |

## Tool Selection Guide

| Need | Use |
|------|-----|
| Quick screenshot + review | **agent-browser** — one-liner, no MCP |
| Token efficiency (constrained context) | **agent-browser** — ~200-400 tokens vs 3000-5000 |
| CI/CD or terminal-only | **agent-browser** — needs no MCP infrastructure |
| Headless local dev | **agent-browser** — purpose-built for this |
| Full accessibility tree semantics | **Playwright MCP** — richer semantic data |
| Complex multi-page interactions | **Playwright MCP** — stateful sessions, richer API |
