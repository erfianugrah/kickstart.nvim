# kickstart.nvim (erfi's fork)

Personal fork of [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), modernized for **Neovim 0.12+**.

## Requirements

- **Neovim >= 0.12.0**
- `git`, `make`, `gcc`, `unzip`, `ripgrep`
- A [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)
- Clipboard tool (`xclip`/`xsel`/`win32yank`)
- Language toolchains as needed (`go`, `node`/`npm`, `python`, `rust`, `deno`, etc.)

## Installation

```sh
git clone https://github.com/erfianugrah/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
nvim  # Lazy will install all plugins on first launch
```

## What's Different From Upstream

Single-file `init.lua` (~990 lines) with these additions on top of kickstart:

### Neovim 0.12 Native Features

| Feature | Details |
|---------|---------|
| LSP commands | `:LspInfo`, `:LspStop`, `:LspRestart`, `:LspLog` (shims around `vim.lsp.*` API; built-in `:lsp` and `:checkhealth vim.lsp` also work) |
| Inlay hints | Enabled by default on attach; `<leader>th` to toggle |
| Code lens | Enabled via `vim.lsp.codelens.enable()`; `grx` to run (built-in keymap) |
| Treesitter selection | `v_an` / `v_in` for incremental node selection (built-in) |
| Undo tree | `:Undotree` (built-in plugin); `<leader>T` to toggle |
| vim.snippet | Native snippet engine used by blink.cmp (LuaSnip removed) |

### LSP Servers (auto-installed via Mason)

| Server | Language(s) |
|--------|-------------|
| `gopls` | Go |
| `ts_ls` | JS/TS (formatting disabled, uses prettier) |
| `denols` | Deno JS/TS (formatting disabled, uses deno fmt) |
| `tailwindcss` | Tailwind CSS |
| `pyright` | Python |
| `rust_analyzer` | Rust |
| `lua_ls` | Lua (Neovim-aware workspace config) |
| `astro` | Astro |
| `cssls` | CSS |
| `jsonls` | JSON |
| `html` | HTML |
| `yamlls` | YAML (with schema associations for k8s, GitHub Actions, Docker Compose, etc.) |
| `graphql` | GraphQL |
| `bashls` | Bash |
| `terraformls` | Terraform |
| `ansiblels` | Ansible |
| `clangd` | C/C++ |
| `dockerls` | Dockerfile |
| `docker_compose_language_service` | Docker Compose |
| `sqlls` | SQL (diagnostics suppressed for Postgres compatibility) |
| `mdx_analyzer` | MDX |
| `markdown_oxide` | Markdown (wiki-links, references) |
| `jqls` | jq |

All servers use `root_markers` (Neovim 0.12 native) instead of lspconfig's `root_pattern()`.

### Formatters (via conform.nvim)

| Formatter | Filetypes | Notes |
|-----------|-----------|-------|
| `prettier` | JS, TS, JSX, TSX, Svelte, Astro, HTML, CSS, JSON, Markdown | |
| `deno fmt` | JS, TS, JSX, TSX | Only runs in Deno projects (gated by `deno.json` presence) |
| `stylua` | Lua | |
| `sqruff` | SQL | Uses project-local `.sqlfluff` if found |
| `caddy fmt` | Caddyfile | |

### Linters (via nvim-lint)

`jsonlint`, `hadolint` (Dockerfile), `tflint` (Terraform), `eslint` (JS) -- only runs linters that are installed.

### Plugins

| Plugin | Purpose | Key Bindings |
|--------|---------|-------------|
| **flash.nvim** | Labeled jump motions | `s` jump, `S` treesitter select, `r` remote (op-pending), `R` treesitter search, `<c-s>` toggle in `/` search |
| **snacks.nvim** | Swiss-army knife | `<leader>gg` lazygit, `<leader>.` scratch buffer, `<leader>S` select scratch, `<leader>n` notification history, `]]`/`[[` next/prev LSP reference |
| **harpoon** | File bookmarks | `<leader>a` add, `<leader>e` menu, `<leader>1-4` quick select |
| **telescope.nvim** | Fuzzy finder | `<leader>sf` files, `<leader>sg` grep, `<leader>sh` help, `<leader>sd` diagnostics, `<leader>/` buffer search, `<leader><leader>` buffers |
| **blink.cmp** | Completion | `<c-y>` accept, `<c-n>`/`<c-p>` navigate, `<c-space>` show docs, `<c-k>` signature help |
| **neo-tree** | File explorer | `\` toggle |
| **trouble.nvim** | Diagnostics panel | `<leader>xx` all diagnostics, `<leader>xX` buffer diagnostics, `<leader>cs` symbols |
| **gitsigns.nvim** | Git signs + hunks | `]c`/`[c` navigate hunks, `<leader>hs` stage, `<leader>hr` reset, `<leader>hp` preview |
| **vim-fugitive** | Git commands | `:Git`, `:Gvdiffsplit`, etc. |
| **diffview.nvim** | Git diff viewer | `:DiffviewOpen`, `:DiffviewFileHistory` |
| **which-key.nvim** | Keymap hints | Appears after pressing `<leader>` (0ms delay) |
| **todo-comments** | TODO/FIXME highlights | `<leader>st` search TODOs |
| **mini.nvim** | Textobjects, surround, statusline | `va)`, `saiw)`, `sd'`, etc. |
| **nvim-dap** | Debug Adapter Protocol | `<F5>` continue, `<F1>` step into, `<F2>` step over, `<leader>b` breakpoint |
| **conform.nvim** | Formatting | `<leader>f` format, auto-format on save |
| **nvim-lint** | Linting | Auto-runs on save |
| **indent-blankline** | Indent guides | Visual only |
| **nvim-autopairs** | Auto-close brackets | Auto |
| **vim-tmux-navigator** | Tmux-aware splits | `<C-h/j/k/l>` navigate splits + tmux panes |
| **gen.nvim** | Ollama AI | Via Cloudflare Access tunnel |
| **markview.nvim** | Markdown preview | In-buffer rendering |
| **twilight + zen-mode** | Focus mode | `:ZenMode`, `:Twilight` |
| **opencode.nvim** | OpenCode AI assistant | `<leader>o` prefix |
| **quarto-nvim** | Quarto notebooks | Otter LSP, vim-slime REPL |

### Treesitter Parsers

Installed via `nvim-treesitter` main branch (rewrite for 0.12+):

```
bash, c, html, lua, diff, luadoc, markdown, markdown_inline, query, vim, vimdoc,
astro, css, csv, javascript, json, terraform, sql, typescript, yaml,
mermaid, xml, http, graphql, go, gomod, gowork, gotmpl,
python, rust, dockerfile, toml
```

Custom `caddyfile` parser installed separately (see below).

Custom injection queries for JavaScript template literals (HTML/CSS/JS in tagged templates).

### Custom Filetype Detection

Defined in `lua/custom/filetype.lua`:

- `.mdx` files
- `.tfvars` / `.tfvars.json` (terraform-vars)
- `.gotmpl` / `go.work` files
- `docker-compose.yml` / `compose.yml` variants
- `.gitlab-ci.yml`
- Ansible playbooks/roles (pattern-based)
- Helm values files

## Key Bindings Reference

### General

| Key | Mode | Action |
|-----|------|--------|
| `<Space>` | n | Leader key |
| `<Esc>` | n | Clear search highlight |
| `<leader>T` | n | Toggle undo tree (native) |
| `<leader>q` | n | Open diagnostic quickfix |
| `<leader>f` | n | Format buffer |
| `<C-h/j/k/l>` | n | Navigate splits (tmux-aware) |

### LSP (available when server attaches)

| Key | Mode | Action |
|-----|------|--------|
| `grn` | n | Rename symbol |
| `gra` | n,x | Code action |
| `grd` | n | Go to definition (via Telescope) |
| `grr` | n | Find references (via Telescope) |
| `gri` | n | Go to implementation (via Telescope) |
| `grt` | n | Go to type definition |
| `grx` | n | Run code lens |
| `grD` | n | Go to declaration |
| `gO` | n | Document symbols |
| `gW` | n | Workspace symbols |
| `K` | n | Hover documentation |
| `<C-s>` | i | Signature help |
| `<leader>th` | n | Toggle inlay hints |

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `s` | n,x,o | Flash jump |
| `S` | n,x,o | Flash treesitter select |
| `]]` / `[[` | n | Next / prev LSP reference |
| `<leader>a` | n | Harpoon: add file |
| `<leader>e` | n | Harpoon: quick menu |
| `<leader>1-4` | n | Harpoon: jump to file 1-4 |

### Search (Telescope)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sf` | n | Find files |
| `<leader>sg` | n | Live grep |
| `<leader>sw` | n,v | Grep current word |
| `<leader>sh` | n | Help tags |
| `<leader>sk` | n | Keymaps |
| `<leader>sd` | n | Diagnostics |
| `<leader>sr` | n | Resume last search |
| `<leader>s.` | n | Recent files |
| `<leader>sc` | n | Commands |
| `<leader>sn` | n | Neovim config files |
| `<leader>/` | n | Fuzzy find in buffer |
| `<leader>s/` | n | Grep in open files |
| `<leader><leader>` | n | Open buffers |

### Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gg` | n | Lazygit (via snacks) |
| `]c` / `[c` | n | Next / prev git hunk |
| `<leader>hs` | n,v | Stage hunk |
| `<leader>hr` | n,v | Reset hunk |
| `<leader>hp` | n | Preview hunk |
| `<leader>hb` | n | Blame line |
| `<leader>hd` | n | Diff against index |

## Structure

```
~/.config/nvim/
  init.lua                  -- Main config (single file)
  lua/
    custom/
      filetype.lua          -- Custom filetype detection
      plugins/
        init.lua            -- Extra plugins (tmux-nav, trouble, zen-mode, etc.)
        caddyfile.lua       -- Caddyfile treesitter + filetype
        opencode.lua        -- OpenCode AI plugin
        quarto.lua          -- Quarto notebook ecosystem
        atac.lua            -- ATAC HTTP client
    kickstart/
      health.lua            -- :checkhealth module
      plugins/
        debug.lua           -- DAP (Go debugging)
        lint.lua            -- nvim-lint config
        gitsigns.lua        -- Git signs + keymaps
        neo-tree.lua        -- File explorer
        autopairs.lua       -- Auto-close brackets
        indent_line.lua     -- Indent guides
  queries/caddyfile/        -- Custom Caddyfile highlight queries
  tree-sitter/caddyfile/    -- Patched Caddyfile grammar (see below)
```

## Caddyfile Tree-sitter Grammar

A patched local fork of [caddyserver/tree-sitter-caddyfile](https://github.com/caddyserver/tree-sitter-caddyfile) lives in `tree-sitter/caddyfile/`. Changes from upstream:

- **layer4 / caddy-l4 support** -- `address_block` + `listener_address` rules for `:port`, `ip:port`, `host:port` blocks
- **Digits in directive names** -- names like `layer4`, `h2c` parse as single tokens
- **Zero-argument matcher directives** -- `@ssh ssh` and `@tls tls` work without extra arguments
- **Standalone `@` argument** -- bare `@` as root-domain marker in `dynamic_dns domains` blocks
- **Single-token `@name`** -- resolves conflicts between named matchers and bare `@`
- Extended placeholder, directive, and argument regex for Caddy-specific syntax
- Bare IPv6 addresses and CIDRs in subdirective contexts like `trusted_proxies`

**Rebuilding the grammar:**

```sh
cd ~/.config/nvim/tree-sitter/caddyfile
# edit grammar.js, then:
tree-sitter generate && tree-sitter test
cc -shared -fPIC -o /tmp/caddyfile.so -I src src/parser.c src/scanner.c -Os
cp /tmp/caddyfile.so ~/.local/share/nvim/site/parser/caddyfile.so
```

Requires [tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/creating-parsers#installation) (`cargo install tree-sitter-cli`).
