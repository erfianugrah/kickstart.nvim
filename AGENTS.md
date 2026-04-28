# Agent Guidelines for kickstart.nvim (erfi's fork)

## Project Overview

Personal Neovim config. Fork of [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), targeting **Neovim 0.12+**. Single `init.lua` (~935 lines) for core config, modular plugin specs in `lua/custom/plugins/` and `lua/kickstart/plugins/`.

## Architecture

### File Layout

```
init.lua                         Core config: options, keymaps, autocmds, LSP servers, inline plugin specs
lua/pg_format_wrapper.lua        SQL post-processor module (fixes pg_format output)
lua/custom/filetype.lua          Custom filetype detection rules
lua/custom/plugins/*.lua         Custom plugin specs (auto-imported by lazy.nvim)
lua/kickstart/plugins/*.lua      Kickstart default plugin specs (auto-imported by lazy.nvim)
queries/caddyfile/               Treesitter highlight/injection queries for Caddyfile
tree-sitter/caddyfile/           Patched Caddyfile tree-sitter grammar (local fork)
```

### Plugin Loading

Lazy.nvim loads plugin specs two ways in `init.lua`:
- Kickstart modules via individual `require` calls (e.g. `require 'kickstart.plugins.debug'`)
- `{ import = 'custom.plugins' }` — auto-imports all `lua/custom/plugins/*.lua`

Each custom plugin file must return a lazy.nvim spec table or list of tables. Do NOT add duplicate `import` directives — `{ import = 'custom.plugins' }` already imports the whole directory.

### Key Dependencies

- **Plugin manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) (bootstrapped in init.lua)
- **LSP**: Native `vim.lsp` (Neovim 0.11+), configured via `vim.lsp.config()` / `vim.lsp.enable()`. `nvim-lspconfig` is included as a **data-only** dep — it ships `lsp/<name>.lua` files Neovim auto-discovers via runtimepath, providing default `cmd`/`filetypes`/`root_markers` for ~250 servers. Neovim itself does NOT bundle these configs.
- **Mason**: Auto-installs LSP servers, formatters, linters via `mason-tool-installer` (static name mapping, no mason-lspconfig)
- **Auto-pairs**: mini.pairs (part of mini.nvim, NOT nvim-autopairs)
- **Formatting**: conform.nvim (`lua/custom/plugins/conform.lua`)
- **Linting**: nvim-lint (`lua/kickstart/plugins/lint.lua`)
- **Completion**: blink.cmp (NOT nvim-cmp)
- **Treesitter**: nvim-treesitter main branch (0.12 rewrite)

## Conventions

### Lua Style
- 2-space indent, single quotes, 160 column width
- Enforced by StyLua (`.stylua.toml`); run `stylua --check .` before committing
- `call_parentheses = "None"` — use `fn { }` not `fn({ })`
- `collapse_simple_statement = "Always"` — one-line `if` blocks OK

### Where to Put Things

| What | Where |
|------|-------|
| New plugin | `lua/custom/plugins/<name>.lua` — return a lazy spec |
| New LSP server | `servers` table in `init.lua` (~line 555) + add Mason name to `mason_names` table (~line 685) |
| New formatter | `lua/custom/plugins/conform.lua` — add to `formatters_by_ft` and `formatters` |
| New linter | `lua/kickstart/plugins/lint.lua` |
| New filetype | `lua/custom/filetype.lua` |
| New treesitter queries | `queries/<language>/` |
| Utility Lua modules | `lua/<name>.lua` (loaded via `require('<name>')`) |

### Naming
- Plugin files: lowercase, hyphen-free (e.g. `opencode.lua` not `open-code.lua`)
- Formatter names in conform: match the binary name (e.g. `pg_format`, `caddyfile_fmt`)
- LSP server names: match Mason registry names

## Removed Plugins (native replacements)

These plugins were removed in favour of Neovim 0.12 native features or bundled alternatives:

- **mason-lspconfig** → static `mason_names` mapping table in `init.lua`
- **fidget.nvim** → `vim.ui.progress_status()` in mini.statusline
- **nvim-autopairs** → `mini.pairs` (bundled in mini.nvim)
- **vim-mdx-js** → treesitter markdown + `mdx_analyzer` LSP
- **vim-fugitive** → lazygit (Snacks) + gitsigns + diffview
- **markview.nvim** → native treesitter markdown highlighting
- **opencode.nvim** → removed (its render-markdown.nvim dep caused heading rendering bugs)

## SQL Formatting

Two-stage pipeline in conform:

1. **`pg_format`** (external) — PostgreSQL-native formatter, handles DDL/`$$` dollar-quoting correctly
2. **`pg_format_fix`** (Lua) — post-processor in `lua/pg_format_wrapper.lua` that fixes:
   - `wrap_function_args()` — breaks multi-arg function calls onto separate lines
   - `fix_split_defaults()` — rejoins `TYPE\nDEFAULT` splits
   - `fix_ddl_parens()` — restores space before `(` in DDL stripped by `--no-space-function`

When modifying SQL formatting behavior, edit `lua/pg_format_wrapper.lua`. Do NOT switch away from pg_format — alternatives (sqruff, sql-formatter, pgfmt) were evaluated and rejected:
- sqruff: cannot parse `$$` dollar-quoting
- sql-formatter: mangles `CREATE POLICY` and other PostgreSQL-specific DDL
- pgfmt: too immature, drops `IF NOT EXISTS`

## Caddyfile Grammar

Patched fork in `tree-sitter/caddyfile/`. After editing `grammar.js`:

```sh
cd tree-sitter/caddyfile
tree-sitter generate && tree-sitter test
cc -shared -fPIC -o /tmp/caddyfile.so -I src src/parser.c src/scanner.c -Os
cp /tmp/caddyfile.so ~/.local/share/nvim/site/parser/caddyfile.so
```

The `src/parser.c` and `src/scanner.c` are generated — do not hand-edit.

## Common Tasks

### Adding a plugin
```lua
-- lua/custom/plugins/my-plugin.lua
return {
  'author/my-plugin',
  event = 'VeryLazy',  -- or other lazy-loading trigger
  opts = {},
}
```

### Adding an LSP server
In `init.lua` (~line 560), add to the `servers` table:
```lua
my_server = {
  root_markers = { 'config-file.json' },
  settings = { ... },
},
```
Mason auto-installs if the server name matches a Mason package.
Also add the Mason package name to `mason_names` table (~line 685) if the lspconfig name differs from the Mason name (e.g. `lua_ls` → `lua-language-server`).

### Adding a formatter
In `lua/custom/plugins/conform.lua`:
```lua
formatters_by_ft = {
  my_filetype = { 'my_formatter' },
},
formatters = {
  my_formatter = {
    command = 'my-fmt',
    args = { '--stdin', '-' },
    stdin = true,
  },
},
```

### Testing changes
- `:checkhealth` — verify LSP, treesitter, providers
- `:ConformInfo` — verify formatter availability and errors
- `:LspInfo` — verify LSP server attachment
- `:Lazy` — plugin management UI

## Things to Avoid

- Do NOT use nvim-lspconfig patterns (`lspconfig.server.setup()`) — this config uses native `vim.lsp.config()`
- Do NOT add plugins directly to `init.lua` — use `lua/custom/plugins/`
- Do NOT install formatters/linters via Mason if they're already system-installed (check with `which`)
- Do NOT duplicate lazy.nvim import directives — `{ import = 'custom.plugins' }` already imports the whole directory
- Do NOT hand-edit generated files in `tree-sitter/caddyfile/src/`
