#!/usr/bin/env node
/**
 * ux-collab CLI — Quick setup for v2.2.0
 * Usage: npx ux-collab <command>
 *
 * Commands:
 *   setup   One-command install (agent-browser, ImageMagick, config)
 *   check   Verify everything is ready
 *   init    Create .ux-collab.md config only
 */

const { spawn } = require('child_process');
const { resolve, join } = require('path');
const { existsSync, writeFileSync } = require('fs');

const SCRIPTS_DIR = join(resolve(__dirname), 'scripts');

function run(script) {
  const path = join(SCRIPTS_DIR, script);
  if (!existsSync(path)) {
    console.error(`Error: ${script} not found`);
    process.exit(1);
  }
  spawn('/bin/bash', [path], { stdio: 'inherit' }).on('close', code => process.exit(code || 0));
}

function init() {
  const path = join(process.cwd(), '.ux-collab.md');
  if (existsSync(path)) {
    console.log('.ux-collab.md already exists');
    process.exit(0);
  }

  writeFileSync(path, `# UX Collab — Project Config

defaultUrl: http://localhost:3000
decisionsDoc: docs/DESIGN_DECISIONS.md

targetFiles:
  tokens: app/globals.css
  components: app/_components/
  
brandTokens:
  colors:
    primary: --color-primary
    secondary: --color-secondary

surfaces:
  - name: Homepage
    route: /

openDecisions: []
`, 'utf8');

  console.log('✔ Created .ux-collab.md — edit with your project settings');
}

function help() {
  console.log(`
ux-collab v2.2.0 — Visual-first UI/UX collaboration

Commands:
  setup   Full install: agent-browser, ImageMagick, config
  check   Verify setup
  init    Create .ux-collab.md config only

Quick Start:
  npx ux-collab setup
  npx ux-collab check

Then tell your agent:
  "Let's work on the UI"
  "Take a screenshot of the dashboard"
`);
}

const cmd = process.argv[2];
switch (cmd) {
  case 'setup': run('setup.sh'); break;
  case 'check': run('check.sh'); break;
  case 'init': init(); break;
  case 'help':
  case '--help':
  case '-h':
  default: help(); break;
}
