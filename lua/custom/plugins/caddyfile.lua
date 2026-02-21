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

-- Set commentstring so gc (comment toggle) works
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'caddyfile',
  callback = function()
    vim.bo.commentstring = '# %s'
  end,
})

-- Register the tree-sitter parser for caddyfile (patched local copy)
-- Source grammar lives in ~/.config/nvim/tree-sitter/caddyfile/
-- After editing grammar.js, run: cd ~/.config/nvim/tree-sitter/caddyfile && tree-sitter generate && tree-sitter test
-- Then in nvim: :TSInstall caddyfile
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
