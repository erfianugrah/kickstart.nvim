-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    config = function()
      require('window-picker').setup {
        hint = 'statusline-winbar',
      }
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    opts = {
      preview = {
        filetypes = { 'markdown', 'quarto', 'rmd', 'typst', 'mdx' },
        hybrid_modes = { 'n' },
        linewise_hybrid_mode = true,
        edit_range = { 1, 1 },
        map_gx = true,
        icon_provider = 'devicons',
        splitview_winopts = {
          split = 'right',
        },
      },
    },
  },
  {
    'preservim/vim-pencil',
    cmd = { 'Pencil', 'PencilOff', 'PencilToggle', 'PencilSoft', 'PencilHard' },
    ft = { 'markdown', 'text', 'tex' },
    init = function()
      vim.g['pencil#wrapModeDefault'] = 'soft'
    end,
  },
  {
    'folke/twilight.nvim',
    cmd = { 'Twilight', 'TwilightEnable', 'TwilightDisable' },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    opts = {
      width = 150,
      wezterm = {
        enabled = true,
        font = '+4',
      },
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
  {
    'David-Kunz/gen.nvim',
    opts = {
      model = 'deepseek-r1:14b', -- The default model to use.
      host = 'ollama.erfianugrah.com', -- The host running the Ollama service.
      port = '443', -- The port on which the Ollama service is listening.
      quit_map = 'q', -- set keymap for close the response window
      retry_map = '<c-r>', -- set keymap to re-send the current prompt
      -- Remote Ollama instance, no local process needed
      command = function(options)
        local client_id = os.getenv 'CLOUDFLARE_ACCESS_OLLAMA_ID'
        local client_secret = os.getenv 'CLOUDFLARE_ACCESS_OLLAMA_SECRET'
        local body = { model = options.model, stream = true }
        local headers = {
          ['CF-Access-Client-Id'] = client_id,
          ['CF-Access-Client-Secret'] = client_secret,
        }
        return 'curl --silent --no-buffer -X POST https://'
          .. options.host
          .. ':'
          .. options.port
          .. '/api/chat -d $body'
          .. ' -H "CF-Access-Client-Id: '
          .. client_id
          .. '"'
          .. ' -H "CF-Access-Client-Secret: '
          .. client_secret
          .. '"'
      end,
      -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
      -- This can also be a command string.
      -- The executed command must return a JSON object with { response, context }
      -- (context property is optional).
      -- list_models = '<omitted lua function>', -- Retrieves a list of model names
      display_mode = 'split', -- The display mode. Can be "float" or "split".
      show_prompt = false, -- Shows the prompt submitted to Ollama.
      show_model = false, -- Displays which model you are using at the beginning of your chat session.
      no_auto_close = false, -- Never closes the window automatically.
      debug = true, -- Prints errors and the command which is run.
    },
  },
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      render = 'virtual',
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewFileHistory' },
  },
  {
    'Piotr1215/presenterm.nvim',
    build = false,
    ft = { 'markdown' },
    opts = {
      default_keybindings = true,
      preview = {
        command = 'presenterm',
        presentation_preview_sync = true,
      },
    },
  },
  -- {
  --   'tris203/precognition.nvim',
  --   --event = "VeryLazy",
  --   config = {
  --     startVisible = true,
  --     showBlankVirtLine = true,
  --     highlightColor = { link = 'Comment' },
  --     hints = {
  --       Caret = { text = '^', prio = 2 },
  --       Dollar = { text = '$', prio = 1 },
  --       MatchingPair = { text = '%', prio = 5 },
  --       Zero = { text = '0', prio = 1 },
  --       w = { text = 'w', prio = 10 },
  --       b = { text = 'b', prio = 9 },
  --       e = { text = 'e', prio = 8 },
  --       W = { text = 'W', prio = 7 },
  --       B = { text = 'B', prio = 6 },
  --       E = { text = 'E', prio = 5 },
  --     },
  --     gutterHints = {
  --       G = { text = 'G', prio = 10 },
  --       gg = { text = 'gg', prio = 9 },
  --       PrevParagraph = { text = '{', prio = 8 },
  --       NextParagraph = { text = '}', prio = 8 },
  --     },
  --   },
  -- },
}
