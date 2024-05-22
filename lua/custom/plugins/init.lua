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
    'wallpants/github-preview.nvim',
    cmd = { 'GithubPreviewToggle' },
    keys = { '<leader>mpt' },
    opts = {
      -- config goes here
    },
    config = function(_, opts)
      local gpreview = require 'github-preview'
      gpreview.setup(opts)

      local fns = gpreview.fns
      vim.keymap.set('n', '<leader>mpt', fns.toggle)
      vim.keymap.set('n', '<leader>mps', fns.single_file_toggle)
      vim.keymap.set('n', '<leader>mpd', fns.details_tags_toggle)
    end,
  },
  -- {
  --   'iamcco/markdown-preview.nvim',
  --   cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  --   ft = { 'markdown' },
  --   build = function()
  --     vim.fn['mkdp#util#install']()
  --   end,
  -- },
  {
    'preservim/vim-pencil',
    init = function()
      vim.g['pencil#wrapModeDefault'] = 'soft'
    end,
  },
  {
    'folke/twilight.nvim',
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    'folke/zen-mode.nvim',
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
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    'David-Kunz/gen.nvim',
    opts = {
      model = 'dolphin-mistral', -- The default model to use.
      host = 'ollama.erfianugrah.com', -- The host running the Ollama service.
      port = '443', -- The port on which the Ollama service is listening.
      quit_map = 'q', -- set keymap for close the response window
      retry_map = '<c-r>', -- set keymap to re-send the current prompt
      init = function(options)
        pcall(io.popen, 'ollama serve > /dev/null 2>&1 &')
      end,
      -- Function to initialize Ollama
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
  { 'brenoprata10/nvim-highlight-colors' },
}
