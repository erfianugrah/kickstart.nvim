# Neovim Config Refactor: Upstream Sync & Fixes

Tracking document for syncing with upstream kickstart.nvim and fixing issues
found during review. Work is done on the `refactor/upstream-sync` branch via a
git worktree at `/tmp/nvim-refactor`.

---

## Bugs

### 1. `custom/filetype.lua` is never loaded

**File:** `lua/custom/filetype.lua`
**Severity:** High

`lua/custom/filetype.lua` defines filetype associations for mdx, tfvars,
docker-compose, ansible, helm, etc. but nothing requires it. The lazy.nvim
import `{ import = 'custom.plugins' }` only loads files under
`lua/custom/plugins/`. All filetype associations in this file are silently
dead.

**Fix:** Add `require('custom.filetype')` to `init.lua` near the top, before
the `lazy.setup()` call (after leader key / option settings).

- [x] Done

---

### 2. `<leader>hu` maps to `stage_hunk` instead of `undo_stage_hunk`

**File:** `lua/kickstart/plugins/gitsigns.lua:43`
**Severity:** High
**Note:** This is also a bug in upstream kickstart.nvim.

```lua
-- Current (wrong):
map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })

-- Should be:
map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
```

- [x] Done

---

### 3. Lint config sets markdown linter then immediately nils it

**File:** `lua/kickstart/plugins/lint.lua:9,42`
**Severity:** Medium

Line 9 sets `markdown = { 'markdownlint' }`, then line 42 sets
`lint.linters_by_ft['markdown'] = nil`. The net effect is no markdown linting,
but the code is contradictory and confusing.

**Fix:** Remove `markdown` from the initial `linters_by_ft` table and remove
the nil assignment. Keep the linters you actually want (json, dockerfile,
terraform, javascript).

- [x] Done

---

### 4. `coq_nvim` is listed but unused

**File:** `init.lua:277`
**Severity:** High

`'ms-jpq/coq_nvim'` is included as a bare plugin with no config/setup. You use
`blink.cmp` for completion. coq loads Lua modules at startup for nothing and
conceptually conflicts with blink.cmp.

**Fix:** Remove the `'ms-jpq/coq_nvim'` line.

- [x] Done

---

## Upstream Sync

### 5. Add `mason-lspconfig.nvim`, drop manual `lsp_to_package` table

**File:** `init.lua` (LSP config block, ~lines 499-805)
**Severity:** High

Upstream now includes `mason-org/mason-lspconfig.nvim` as a dependency of
`nvim-lspconfig`. This plugin automatically resolves lspconfig server names to
Mason package names, eliminating the need for the manual `lsp_to_package`
mapping table (lines 759-780).

Your manual table is missing mappings for: `markdown_oxide`, `mdx_analyzer`,
`astro`, `jqls`, and others -- meaning those servers won't auto-install.

**Fix:**
1. Add `'mason-org/mason-lspconfig.nvim'` to the lspconfig dependencies.
2. Remove the manual `lsp_to_package` table and the loop that uses it.
3. Simplify `ensure_installed` to use `vim.tbl_keys(servers)` plus extra tools.

- [x] Done

---

### 6. Add luv/busted to `lua_ls` workspace library

**File:** `init.lua` (lua_ls config, ~line 826)
**Severity:** Medium

Upstream now includes `${3rd}/luv/library` and `${3rd}/busted/library` in the
lua_ls workspace library config. This provides type completions for `vim.uv` /
`vim.loop` and the busted test framework.

```lua
-- Current:
library = vim.api.nvim_get_runtime_file('', true),

-- Upstream:
library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
  '${3rd}/luv/library',
  '${3rd}/busted/library',
}),
```

- [x] Done

---

### 7. Remove manual `blink.cmp` capability injection from lspconfig

**File:** `init.lua` (LSP config, ~lines 613-614, 802)
**Severity:** Medium

Upstream removed `saghen/blink.cmp` from the nvim-lspconfig dependencies and
no longer calls `require('blink.cmp').get_lsp_capabilities()`. blink.cmp v1
registers its capabilities automatically via `vim.lsp.config('*', ...)`.

```lua
-- Remove from lspconfig dependencies:
'saghen/blink.cmp',

-- Remove from config function:
local capabilities = require('blink.cmp').get_lsp_capabilities()
-- ...
config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
```

Each server config can just be passed directly to `vim.lsp.config()` without
capability merging.

- [x] Done

---

### 8. Add `gr` LSP Actions group to which-key spec

**File:** `init.lua` (which-key opts, ~line 331)
**Severity:** Medium

Upstream added a which-key group for the `gr` prefix used by LSP keymaps:

```lua
{ 'gr', group = 'LSP Actions', mode = { 'n' } },
```

Your config is missing this, so pressing `gr` and waiting won't show the LSP
action submenu labels.

- [x] Done

---

### 9. Add `@module`/`@type` annotations for lua_ls support

**Files:** `init.lua`, `lua/kickstart/plugins/*.lua`
**Severity:** Low

Upstream added type annotations throughout for better lua_ls completions when
editing the config itself:

- `---@module 'gitsigns'` / `---@type Gitsigns.Config`
- `---@module 'conform'` / `---@type conform.setupOpts`
- `---@type table<string, vim.lsp.Config>` on the servers table
- `---@module 'which-key'` / `---@type wk.Opts`
- Various `---@diagnostic disable-next-line: missing-fields`

**Fix:** Add annotations to match upstream where applicable.

- [x] Done

---

### 10. Align diagnostic `underline` severity format

**File:** `init.lua:195`
**Severity:** Low

Upstream changed to the filter-table format:

```lua
-- Current:
underline = { severity = vim.diagnostic.severity.ERROR },

-- Upstream:
underline = { severity = { min = vim.diagnostic.severity.WARN } },
```

The `{ min = ... }` format is the correct `vim.diagnostic.severity` filter
spec. Whether to use WARN or ERROR is a preference -- but the format should be
updated.

- [x] Done

---

### 11. Plan treesitter migration to new `branch = 'main'` API

**File:** `init.lua` (treesitter config, ~lines 1065-1164)
**Severity:** Low (defer)

Upstream completely rewrote the treesitter config to use the new
`nvim-treesitter` main branch API (`vim.treesitter.start()`,
`vim.treesitter.language.add()`, `require('nvim-treesitter').install()`).

Your config uses the legacy `require('nvim-treesitter.configs').setup()` API
with `main = 'nvim-treesitter.config'`. This still works but is the old
approach.

**Complicating factors for migration:**
- Custom JS template string injection queries (`init.lua:1131-1163`)
- Custom caddyfile parser registration via `get_parser_configs()`
  (`lua/custom/plugins/caddyfile.lua:29`)
- `incremental_selection` config
- `auto_install = true` (no equivalent in new API)

**Recommendation:** Defer this to a separate branch. Test that:
1. All your parsers install correctly with the new `.install()` API
2. Custom caddyfile parser still registers
3. JS injection queries still work with `vim.treesitter.start()`
4. Folding for JSON still works

- [ ] Deferred to separate branch

---

## Cleanup

### 12. Remove one of the duplicate markdown preview plugins

**File:** `lua/custom/plugins/init.lua`
**Severity:** Medium

Three markdown preview/rendering plugins are installed:
- `markdown-preview.nvim` (lines 34-42) -- browser-based, renders mermaid/math
- `github-preview.nvim` (lines 17-33) -- browser-based, GitHub-flavored
- `markview.nvim` (lines 43-59) -- in-buffer rendering

`markdown-preview.nvim` and `github-preview.nvim` overlap heavily (both open a
browser preview). Pick one.

- `markdown-preview.nvim`: more mature, wider adoption, renders mermaid/katex
- `github-preview.nvim`: better GitHub-flavored fidelity, live sync

`markview.nvim` is distinct (in-buffer rendering) and complements either.

**Decision needed from user.**

- [x] Done

---

### 13. Consolidate gitsigns config to one location

**Files:** `init.lua:296-306`, `lua/kickstart/plugins/gitsigns.lua`
**Severity:** Low

Gitsigns is configured in two places. lazy.nvim merges the `opts` tables so it
works, but it's confusing to maintain. Consider moving the sign character
config from `init.lua` into `lua/kickstart/plugins/gitsigns.lua`.

- [x] Done

---

### 14. Remove disabled `molten-nvim` block

**File:** `lua/custom/plugins/quarto.lua:131-150`
**Severity:** Low

The `molten-nvim` plugin spec has `enabled = false`. Dead config that adds
noise.

- [x] Done

---

### 15. Fix `gen.nvim` init function (no-op for remote Ollama)

**File:** `lua/custom/plugins/init.lua:137-139`
**Severity:** Low

The `init` function runs `ollama serve` locally, but your Ollama instance is
remote (`ollama.erfianugrah.com`). This is a harmless no-op but misleading.

```lua
-- Current (pointless for remote):
init = function(options)
  pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
end,

-- Fix: remove or replace with a no-op comment
init = nil, -- remote Ollama, no local process needed
```

- [x] Done

---

### 16. Restrict global spellcheck to prose filetypes

**File:** `init.lua:91-92`
**Severity:** Low

`vim.opt.spell = true` is set globally, causing spellcheck squiggles on
variable names in code buffers.

**Fix:** Remove the global `vim.opt.spell = true` and use an autocmd:

```lua
vim.opt.spelllang = 'en_gb'
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit', 'quarto', 'norg' },
  callback = function() vim.opt_local.spell = true end,
})
```

- [x] Done

---

### 17. Neo-tree `lazy = false` forces eager load

**File:** `lua/kickstart/plugins/neo-tree.lua:12`
**Severity:** Low
**Note:** Upstream also has `lazy = false`, so this is intentional upstream.

The `keys` spec (`\\`) already provides lazy-loading. Removing `lazy = false`
would defer loading until first use, improving startup time. However, upstream
keeps it for immediate filesystem watching.

**Decision:** Keep as-is (matches upstream intent) or remove for faster
startup.

- [x] Done

---

### 18. Denols formatter used for non-Deno JS/TS projects

**File:** `init.lua:866-871`
**Severity:** Low

All JS/TS filetypes use `denols` (deno fmt) as the formatter. In non-Deno
projects this still works but produces different formatting than prettier.

**Fix (optional):** Use `stop_after_first` with a fallback:

```lua
javascript = { 'denols', 'prettier', stop_after_first = true },
typescript = { 'denols', 'prettier', stop_after_first = true },
```

Or keep as-is if you prefer deno fmt universally.

- [x] Done

---

## Healthcheck Fixes (post-merge)

### 19. Switch blink.cmp fuzzy to rust implementation

**File:** `init.lua` (blink.cmp config)

Changed `fuzzy = { implementation = 'lua' }` to
`fuzzy = { implementation = 'prefer_rust_with_warning' }`. The rust fuzzy
matcher is recommended and eliminates the "lib not downloaded" warning. Falls
back to Lua if the binary can't be fetched.

- [x] Done

---

### 20. img-clip: install `wl-clipboard` for WSL2

**System fix** -- not a config change.

Run: `sudo pacman -S wl-clipboard`

- [ ] Requires manual sudo

---

### 21. Disable jupytext.nvim (upstream nvim 0.11 incompatibility)

**File:** `lua/custom/plugins/quarto.lua`

jupytext.nvim uses deprecated `vim.health.report_start` and old-style
`vim.validate` (Neovim 0.11 removed these). The plugin is on its latest
version. The `jupytext` CLI is also not installed, so the plugin is
non-functional anyway. Disabled with `enabled = false` until upstream fixes.

- [x] Done

---

### 22. Disable unused remote providers

**File:** `init.lua` (top of file)

Added provider disables to suppress healthcheck warnings for languages not
used as Neovim remote plugin hosts:

```lua
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
```

- [x] Done

---

### 23. Clear bloated LSP log (236MB)

**System fix:** `truncate -s 0 ~/.local/state/nvim/lsp.log`

Log level is already set to `'error'` which prevents rapid regrowth.

- [x] Done

---

### 24. Fix `<Space>q` / `<Space>qm` keymap overlap

**File:** `lua/custom/plugins/quarto.lua`

nabla.nvim math toggle was mapped to `<leader>qm`, overlapping with the
`<leader>q` diagnostic quickfix list keymap. Moved to `<leader>tm` (Toggle
math) which fits the `[T]oggle` group convention.

- [x] Done
