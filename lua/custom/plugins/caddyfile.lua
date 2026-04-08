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
-- Then copy the compiled .so: cp parser/caddyfile.so ~/.local/share/nvim/site/parser/caddyfile.so
--
-- Register parser definition so :TSInstall caddyfile works.
-- Uses User TSUpdate autocmd to survive nvim-treesitter's reload_parsers() cache wipe.
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = function()
    local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
    if ok then
      parsers.caddyfile = parsers.caddyfile or {
        install_info = {
          url = vim.fn.stdpath 'config' .. '/tree-sitter/caddyfile',
        },
        tier = 4,
      }
    end
  end,
})

return {}
