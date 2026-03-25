return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        json = { 'jsonlint' },
        dockerfile = { 'hadolint' },
        terraform = { 'tflint' },
        javascript = { 'eslint' },
      }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if not vim.bo.modifiable then
            return
          end

          -- Only run linters that are available
          local linters = require('lint').linters_by_ft[vim.bo.filetype] or {}
          local available_linters = {}
          for _, linter in ipairs(linters) do
            local linter_config = require('lint').linters[linter]
            local cmd = linter_config and linter_config.cmd
            -- cmd can be a string or a function, resolve it first
            if type(cmd) == 'function' then
              cmd = cmd()
            end
            if type(cmd) == 'string' and vim.fn.executable(cmd) == 1 then
              table.insert(available_linters, linter)
            end
          end
          if #available_linters > 0 then
            require('lint').try_lint(available_linters)
          end
        end,
      })
    end,
  },
}
