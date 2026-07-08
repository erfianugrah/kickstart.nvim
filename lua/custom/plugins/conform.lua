return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true, lsp_format = 'fallback' } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 2500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'denols', 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'denols', 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'denols', 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'denols', 'prettierd', 'prettier', stop_after_first = true },
      svelte = { 'denols', 'prettierd', 'prettier', stop_after_first = true },
      astro = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      sql = { 'pg_format', 'pg_format_fix' },
      caddyfile = { 'caddyfile_fmt' },
    },
    formatters = {
      -- prettierd (daemon) is primary: no ~200ms node cold-start per save, and it
      -- does NOT silently skip .gitignore'd files the way the prettier CLI does.
      prettierd = {
        command = 'prettierd',
        args = { '$FILENAME' },
        stdin = true,
      },
      -- prettier CLI fallback (used only if the prettierd daemon isn't on PATH).
      -- --ignore-path /dev/null: prettier 3.x consults .gitignore by default and
      -- no-ops on gitignored files (e.g. secret-bearing *.profile.json). We're
      -- actively editing the buffer, so format regardless of gitignore status.
      prettier = {
        command = 'prettier',
        args = { '--ignore-path', '/dev/null', '--stdin-filepath', '$FILENAME' },
        stdin = true,
      },
      denols = {
        command = 'deno',
        args = function(_, ctx)
          local ext = vim.fn.fnamemodify(ctx.filename, ':e')
          return { 'fmt', '--ext', ext, '-' }
        end,
        stdin = true,
        condition = function(_, ctx) return #vim.fs.find({ 'deno.json', 'deno.jsonc' }, { path = ctx.dirname, upward = true }) > 0 end,
      },
      pg_format = {
        command = 'pg_format',
        args = { '--spaces', '2', '--no-space-function', '-' },
        stdin = true,
      },
      pg_format_fix = {
        format = function(_, _, lines, callback)
          local fix = require 'pg_format_wrapper'
          local result = fix.fix_split_defaults(lines)
          result = fix.fix_ddl_parens(result)
          result = fix.wrap_function_args(result, '  ')
          callback(nil, result)
        end,
      },
      caddyfile_fmt = {
        command = 'caddy',
        args = { 'fmt', '-' },
        stdin = true,
      },
    },
  },
}
