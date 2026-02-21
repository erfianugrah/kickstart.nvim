-- Caddyfile tree-sitter support
-- Based on: https://github.com/caddyserver/tree-sitter-caddyfile
-- Patched: placeholder regex allows hyphens (e.g. {http.request.header.CF-Connecting-IP})

-- Register filetype detection for Caddyfile
vim.filetype.add {
  filename = {
    ['Caddyfile'] = 'caddyfile',
  },
  pattern = {
    ['.*Caddyfile'] = 'caddyfile',
    ['.*Caddyfile.*'] = 'caddyfile',
    ['*.caddyfile'] = 'caddyfile',
  },
}

-- Register the tree-sitter parser for caddyfile (patched local copy)
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.caddyfile = {
  install_info = {
    url = vim.fn.stdpath 'config' .. '/tree-sitter/caddyfile',
    files = { 'src/parser.c', 'src/scanner.c' },
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'caddyfile',
}

return {}
