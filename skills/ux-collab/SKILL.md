---
name: ux-collab
description: "Visual-first UI/UX collaboration loop using agent-browser (primary), Playwright MCP (alternative), and Lucid (wireframes). Use when designing or iterating on UI, reviewing the live app visually, creating wireframes, making layout decisions, discussing design before building, or running a design→build→verify loop. Trigger phrases: 'let's work on the UI', 'show me what it looks like', 'create a wireframe', 'design the layout', 'take a screenshot', 'browser view', 'before we build let's decide'."
compatibility: "Requires: agent-browser (brew/npm) OR Playwright MCP (mcp_playwright_*). ImageMagick (convert + identify CLI) for screenshot optimization. Optional: Lucid MCP (mcp_lucid_*) — falls back to Markdown wireframes when unavailable."
license: MIT
metadata:
  author: kylebrodeur
  version: "2.1"
---

# UX Collaboration Skill

A structured loop for visual-first UI/UX design and implementation. Works with any web app running locally — project-specific routes, surfaces, and brand tokens are configured per-project via `.ux-collab.md` (see [Project Setup](docs/project-setup.md)).

## When to Use

- Any session where UI/UX decisions need to be made before or during coding
- When the user wants to see the live app, discuss layout, or compare before/after states
- When a design decision is unresolved and a wireframe would help
- When iterating on an existing surface

## Prerequisites — Check Before Starting

At session start, verify the required tools are available. **agent-browser is preferred** — use Playwright MCP only when you need specific features it provides.

```
1. agent-browser (PRIMARY)
   → Check: agent-browser --version
   → Install if missing:
      brew install agent-browser          # macOS (fastest)
      npm install -g agent-browser          # any platform
   → First run: agent-browser install      # Downloads Chrome for Testing

2. ImageMagick (screenshot optimization)
   → Check: which convert && which identify
   → Install:
      brew install imagemagick             # macOS
      sudo apt install imagemagick         # Ubuntu/Debian

3. Playwright MCP (ALTERNATIVE — use when needed)
   → Try: mcp_playwright_browser_navigate { url: "about:blank" }
   → When to use Playwright instead of agent-browser:
      * Need full accessibility tree with semantic roles
      * Complex multi-page interactions with state
      * Specific viewport/device emulation
      * MCP ecosystem already configured and working
   → Fallback: if MCP unavailable, agent-browser handles all core needs

4. Lucid MCP (OPTIONAL — for wireframes)
   → If unavailable, use Markdown wireframe fallback (Step 3b)

5. Dev server
   → Navigate to target URL; if unreachable, check Session Startup Checklist
```

---

## Browser Tool Selection Guide

| Use **agent-browser** when | Use **Playwright MCP** when |
|---|---|
| Quick visual review | Need full accessibility tree |
| Token efficiency matters (~200-400 tokens vs 3000-5000) | Complex multi-page interactions |
| Headless, local development | Specific geolocation/permissions |
| CI/CD or terminal-only environments | Rich semantic element analysis |
| Screenshot + basic interaction needed | Viewport resizing via MCP tools |

**Default workflow**: Start with agent-browser. Switch to Playwright MCP if you hit limitations.

---

## The Loop

```
SEE → DISCUSS → DESIGN → BUILD → VERIFY → RECORD
```

### Step 1 — SEE (Browser Snapshot)

Open the live app and establish shared visual context.

**Primary approach (agent-browser):**
```bash
agent-browser open <target-url>     # Navigate
agent-browser snapshot -i             # Get accessibility tree with refs
agent-browser screenshot page.png     # Full page screenshot
./optimize-screenshot.sh              # Optimize for chat (<80KB)
```

**Alternative (Playwright MCP) when richer features needed:**
```
Actions:
- mcp_playwright_browser_navigate → target URL
- mcp_playwright_browser_take_screenshot { type: "png" }
- ./optimize-screenshot.sh
- mcp_playwright_browser_snapshot (full accessibility tree)
- mcp_playwright_browser_resize for responsive checks:
    mobile:  390×844
    tablet:  768×1024
    desktop: 1440×900
```

**Screenshot optimization is mandatory** before attaching any screenshot to chat. Raw screenshots can exceed 280KB. The optimize script resizes to max 1280px wide and converts to JPEG at 82% quality — output reliably lands under 80KB.

```bash
# Optimize latest screenshot automatically:
./optimize-screenshot.sh

# Or optimize a specific file:
./optimize-screenshot.sh /path/to/screenshot.png
```

After capturing, state your observations in **3–5 bullet points**:
- Overall layout and visual hierarchy
- Empty states or placeholder content
- Interaction affordances (buttons, inputs, links)
- Spacing and alignment issues
- Anything that looks broken or unfinished

### Step 2 — DISCUSS

Synthesize observations into design questions. Ask **exactly one focused question** at a time.

**Types of design questions (pick the right frame):**

| Question type | When to use | Example |
|---|---|---|
| **Layout** | Structure or grid is unclear | "Should this stack vertically on mobile or stay side-by-side?" |
| **Hierarchy** | Content priority is ambiguous | "Is the headline or the CTA the primary element here?" |
| **Pattern** | Multiple valid UI patterns exist | "Would a stepped form or all-at-once scroll work better for this survey?" |
| **State** | Empty/error/loading states are missing | "What should appear when there are no results yet?" |
| **Interaction** | Click/hover/focus behavior is undefined | "Should filtering update results live or require a submit?" |

Check the project decisions doc (from `.ux-collab.md` → `decisionsDoc`) before asking — don't re-litigate resolved decisions.

### Step 3a — DESIGN (Lucid) — When Lucid MCP is available

When structural or layout decisions need visual communication, produce a Lucid wireframe.

```
Actions:
- mcp_lucid_lucid_create_diagram_from_specification → generate wireframe
- mcp_lucid_lucid_create_document_share_link → share (get email from .ux-collab.md or ask)
- mcp_lucid_lucid_export_image → pull image back into conversation
- mcp_playwright_browser_navigate → open diagram URL for review
```

**Wireframe conventions:**
- Label everything: component name, content type, interaction state (empty/filled/error/disabled)
- Show the dominant layout grid (column count, gaps, max-width)
- Include mobile and desktop artboards when layout changes significantly across breakpoints
- Use brand token names in labels (e.g., `bg-brand-navy`, `text-brand-gold`) — check `.ux-collab.md` for project tokens
- Mark unresolved decisions as `[?]` in the diagram

**When to wireframe vs. just describe:**
- **Wireframe**: new surface, layout restructure, before/after comparison, multiple competing options
- **Describe**: minor spacing/color tweaks, copy changes, single-component fixes

### Step 3b — DESIGN (Markdown Fallback) — When Lucid MCP is unavailable

Produce a structured Markdown wireframe directly in chat:

```markdown
## Wireframe: [Surface Name] — [Viewport]

Layout: [describe grid, e.g., "2-col, 16px gap, max-w-4xl centered"]

┌─────────────────────────────────────┐
│  [HEADER]  Logo        Nav links    │
├─────────────────────────────────────┤
│  [HERO]                             │
│  H1: Primary headline               │
│  Body: Supporting copy              │
│  [CTA Button — brand-gold]          │
├─────────────┬───────────────────────┤
│  [SIDEBAR]  │  [MAIN CONTENT]       │
│  Filter A   │  Card grid (3-col)    │
│  Filter B   │  ...                  │
└─────────────┴───────────────────────┘

States needed: empty, loading, error, filled
Open decisions: [?] sidebar collapse behavior on mobile
```

Label open decisions with `[?]`. Get explicit agreement before moving to BUILD.

### Step 4 — BUILD

Implement only what was agreed in Steps 2–3. No scope creep.

**Project-specific target files are in `.ux-collab.md`** — read it before touching any files.

If no `.ux-collab.md` exists, discover targets by:
```bash
# Find the component and style entrypoints
find . -name "globals.css" -not -path "*/node_modules/*" | head -5
find . -name "tailwind.config*" -not -path "*/node_modules/*" | head -3
ls app/ components/ src/ 2>/dev/null | head -20
```

**Universal code rules:**
- All colors via design tokens only — no inline hex values
- Use the project's existing component system (shadcn/ui, Radix, MUI, etc.) — extend, don't replace
- No new dependencies without explicit discussion
- Keep accessibility semantics: correct heading levels, button vs. link, ARIA labels on interactive elements

### Step 5 — VERIFY (Browser Verification)

After every code change, reload and compare.

**Primary approach (agent-browser):**
```bash
agent-browser open <target-url>       # Re-open/reload
agent-browser snapshot -i             # Get updated accessibility tree
agent-browser screenshot page.png     # Capture after state
./optimize-screenshot.sh
```

**For interactions:**
```bash
agent-browser scroll down 500         # Scroll to content
agent-browser click @e3               # Click element by ref
agent-browser screenshot page.png     # Capture result
```

**Alternative (Playwright MCP) when richer verification needed:**
```
Actions:
- mcp_playwright_browser_navigate → reload route
- mcp_playwright_browser_take_screenshot → capture after state
- ./optimize-screenshot.sh
- mcp_playwright_browser_scroll_down / click through key interactions
- mcp_playwright_browser_evaluate → inspect computed styles
```

**Visual diff**: Side-by-side compare before/after. Call out:
- ✅ What changed and matches intent
- ⚠️ What's still off
- ❌ What regressed

**Accessibility audit** — run after every significant change:
```
With agent-browser:
  agent-browser snapshot -i             # Review accessibility tree
  Look for: heading hierarchy, button labels, form labels, ARIA roles

With Playwright MCP:
  mcp_playwright_browser_snapshot → full accessibility tree
  mcp_playwright_browser_evaluate → getComputedStyle for contrast checks
```

**Responsive check matrix:**
```bash
# agent-browser approach — resize window manually or use device flag
agent-browser --device "iPhone 12" open <url>
agent-browser screenshot mobile.png

agent-browser --device "iPad" open <url>
agent-browser screenshot tablet.png
```

Or with Playwright MCP:
```
mcp_playwright_browser_resize { width: 390, height: 844 }   # Mobile
mcp_playwright_browser_resize { width: 768, height: 1024 }  # Tablet
mcp_playwright_browser_resize { width: 1440, height: 900 } # Desktop
```

Take a screenshot at each breakpoint when layout changes significantly.

### Step 6 — RECORD

Update the project decisions doc (path in `.ux-collab.md` → `decisionsDoc`, default: `docs/DESIGN_DECISIONS.md`).

Move resolved decisions from "Open" to "Decided":

```markdown
**[Decision name]** — [chosen option].
Rationale: [one sentence why].
Date: [YYYY-MM].
```

If no decisions doc exists yet, create one with sections:
- `## Open Decisions`
- `## Decided`
- `## Design Principles` (for persistent rules that came out of discussion)

---

## Minimal Mode — Quick Visual Review

For lightweight sessions (no wireframe, no build) — just SEE + DISCUSS:

**With agent-browser:**
```bash
agent-browser open <target-url>
agent-browser screenshot page.png
./optimize-screenshot.sh
# State 3–5 observations, ask one focused question
```

**With Playwright MCP:**
```
1. mcp_playwright_browser_navigate → target URL
2. mcp_playwright_browser_take_screenshot
3. ./optimize-screenshot.sh
4. State 3–5 observations
5. Ask one focused question
```

Use this when:
- User wants a fast gut-check before a full session
- Verifying a single deployed fix
- Getting visual context before planning work

---

## Session Startup Checklist

```
[ ] agent-browser installed and working?
    → Check: agent-browser --version
    → Install: brew install agent-browser OR npm i -g agent-browser
    → First run: agent-browser install

[ ] Playwright MCP available (backup/alternative)?
    → Try: mcp_playwright_browser_navigate to "about:blank"
    → If agent-browser fails, use Playwright MCP

[ ] Dev server running?
    → Check: agent-browser open <target-url>
    → Start: run the project's dev task / npm run dev / pnpm dev

[ ] Read .ux-collab.md (if it exists in the project root)
    → Sets: defaultUrl, decisionsDoc, brandTokens, targetFiles, surfaces

[ ] Take baseline screenshot of target surface
    → agent-browser open <url> + agent-browser screenshot + ./optimize-screenshot.sh

[ ] Check decisions doc for any choices made last session
    → path from .ux-collab.md, default: docs/DESIGN_DECISIONS.md

[ ] Confirm scope: which surface and which decision is in scope today
```

---

## Quick Reference

### agent-browser (Primary)

```bash
# Installation
brew install agent-browser           # macOS
npm install -g agent-browser         # any platform
agent-browser install                # Download Chrome (first-time)

# Core workflow
Navigate:    agent-browser open <url>
Screenshot:  agent-browser screenshot [path.png] [--full]
Optimize:    ./optimize-screenshot.sh
              → /tmp/playwright-screenshots-optimized/*-opt.jpg (<80KB)
Snapshot:    agent-browser snapshot -i  (accessibility tree with refs)
Click:       agent-browser click @<ref>  (from snapshot)
Scroll:      agent-browser scroll <up/down/left/right> [px]
Close:       agent-browser close

# Responsive testing
Devices:     agent-browser --device "iPhone 12" open <url>
             agent-browser --device "iPad" open <url>
             agent-browser --device "Pixel 5" open <url>

# Sessions (isolated browser instances)
Create:      agent-browser --session <name> open <url>
List:        agent-browser session list
Close all:   agent-browser close --all

# Configuration
Config file: agent-browser.json (project root or ~/.agent-browser/config.json)
Headed mode: agent-browser open <url> --headed
State saving: agent-browser --profile ./profile open <url>
```

### Playwright MCP (Alternative)

```
Navigate:    mcp_playwright_browser_navigate { url }
Screenshot:  mcp_playwright_browser_take_screenshot { type: "png" }
Optimize:    ./optimize-screenshot.sh
              → /tmp/playwright-screenshots-optimized/*-opt.jpg (<80KB)
Snapshot:    mcp_playwright_browser_snapshot  (full a11y tree + element refs)
Click:       mcp_playwright_browser_click { ref }
Resize:      mcp_playwright_browser_resize { width, height }
Evaluate:    mcp_playwright_browser_evaluate { script }
Scroll:      mcp_playwright_browser_mouse_wheel { deltaY }
```

### Lucid

```
Create:      mcp_lucid_lucid_create_diagram_from_specification { title, description, ... }
Share:       mcp_lucid_lucid_create_document_share_link { documentId, email }
Export:      mcp_lucid_lucid_export_image { documentId }
Preview:     agent-browser open <lucidShareUrl>
              OR: mcp_playwright_browser_navigate { url: lucidShareUrl }
```

---

## Project Configuration

This skill is project-agnostic. Project-specific settings (target URL, brand tokens, file paths, surfaces, open decisions) live in a `.ux-collab.md` file at your project root.

See [docs/project-setup.md](docs/project-setup.md) for the full `.ux-collab.md` format and examples.

**At session start: always check for `.ux-collab.md` and read it if present.**
