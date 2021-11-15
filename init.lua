-- This is my init.lua! I refuse to:
-- * Use vimscript
-- * Split this into multiple files
-- * Format it nicely
-- * Write the comments in a way that make sense to people other than me
-- Ok! Have fun!

-- Utilities! Stolen from Jesse Atkinson, who in turn stole from Chris Kipp
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

local function opt(scope, key, value)
  local scopes = {o = vim.o, b = vim.bo, w = vim.wo}
  scopes[scope][key] = value
  if scope ~= "o" then
    scopes["o"][key] = value
  end
end

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Let's set some basic options
-- Visible stuff
opt("w", "number", true)
opt("o", "showcmd", true)
opt("o", "laststatus", 2)
opt("o", "signcolumn", "yes")
opt("o", "wrap", false)
opt("o", "showmode", false)

-- Window management:
opt("o", "hidden", true)
opt("o", "splitbelow", true)
opt("o", "splitright", true)

-- I like the spacebar, it is the only key on my dumb little keyboard that is any bigger
g["mapleader"] = " "
g["maplocalleader"] = " "

-- I also like the mouse sometimes
opt("o", "mouse", "nicr")

-- Two spaces! Please!
opt("o", "tabstop", 2)
opt("o", "softtabstop", 2)
opt("o", "shiftwidth", 2)
opt("o", "expandtab", true)
opt("o", "smartindent", true)

-- Let's keep an undofile
opt("o", "autowrite", true)
opt("o", "undofile", true)
opt("o", "backup", false)
opt("o", "writebackup", false)
opt("o", "swapfile", false)

-- Fix multi-byte emoji
opt("o", "emo", false)

-- And now, plugins:
cmd([[packadd packer.nvim]])
require("packer").startup(
  function()
    -- Packer can manage itself as an optional plugin.
    use "wbthomason/packer.nvim"

    -- Colorscheme!
    use "nvim-treesitter/nvim-treesitter"
    use "projekt0n/github-nvim-theme"

    -- Lumpy Space Princess
    use "tami5/lspsaga.nvim"
    use {
      "neovim/nvim-lspconfig",
      "williamboman/nvim-lsp-installer"
    }

    -- Formatting
    use "mhartington/formatter.nvim"

    -- Search and find
    use {
      "nvim-telescope/telescope.nvim",
      requires = {{"nvim-lua/plenary.nvim"}}
    }

    -- Lines!
    use {
      "hoob3rt/lualine.nvim",
      requires = {"kyazdani42/nvim-web-devicons", opt = true}
    }
    use {"akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons"}

    -- Get rid of buffers easily
    use "famiu/bufdelete.nvim"

    -- What's wrong??
    use(
      {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons"
      }
    )

    -- Autocompletion
    use {"ms-jpq/coq_nvim", branch = "coq"}
    use {"ms-jpq/coq.artifacts", branch = "artifacts"}

    -- Nice netrw
    use "tpope/vim-vinegar"
    -- Comment stuff out
    use "tpope/vim-commentary"
    -- Allow some extra things to repeat with `.`
    use "tpope/vim-repeat"

    -- Surround
    use {
      "blackCauldron7/surround.nvim",
      config = function()
        require "surround".setup {mappings_style = "sandwich"}
      end
    }

    -- Registers
    use "tversteeg/registers.nvim"

    -- Simple tweak to highlighting and searching in file
    use "rktjmp/highlight-current-n.nvim"

    -- Gitgutters
    use {
      "lewis6991/gitsigns.nvim",
      requires = {
        "nvim-lua/plenary.nvim"
      },
      config = function()
        require("gitsigns").setup()
      end
    }

    -- Context
    use "romgrk/nvim-treesitter-context"

    -- Move!
    use "phaazon/hop.nvim"
    use "chaoren/vim-wordmotion"

    -- Allow for dispatching my browser
    use "tyru/open-browser.vim"
    -- Open current file in github repo
    use "tyru/open-browser-github.vim"

    -- Let's make a colorscheme
    use "rktjmp/lush.nvim"
  end
)

-- Theming
if fn.has("termguicolors") == 1 then
  opt("o", "termguicolors", true)
end
require("github-theme").setup(
  {
    theme_style = "dark_default",
    function_style = "italic"
  }
)

-- Some mapping

-- :Explore! It's good, actually
map("", "<leader>e", ":Explore<cr>")

-- Easy config reload
map("n", "<leader>vr", ":source ~/.config/nvim/init.lua<cr>")
map("n", "<leader>vp", ":PackerInstall<cr>")

-- Jump to file in github
map("n", "<leader>g", ":OpenGithubFile<cr>")
-- Last file
map("n", "<leader><leader>", "<c-^>")

-- Clear search highlighting easily
map("n", "<backspace>", ":noh<cr>")

-- LSP
local lspconf = require("lspconfig")
local coq = require("coq")

g.coq_settings = {
  auto_start = true and "shut-up",
  keymap = {
    jump_to_mark = ""
  }
}
api.nvim_command("autocmd VimEnter * COQnow --shut-up") -- no idea why I need this with the above

local lsp_installer = require("nvim-lsp-installer")

lsp_installer.on_server_ready(
  function(server)
    local opts = {}

    -- (optional) Customize the options passed to the server
    if server.name == "eslint" then
      opts.settings = {
        run = "onSave"
      }
    end

    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
  end
)

local saga = require "lspsaga"

saga.init_lsp_saga {
  max_preview_lines = 24,
  finder_action_keys = {
    open = "<CR>",
    vsplit = "v",
    split = "s",
    quit = "<Esc>",
    scroll_down = "<Down>",
    scroll_up = "<Up>"
  },
  code_action_keys = {
    quit = "<Esc>",
    exec = "<CR>"
  },
  rename_action_keys = {
    quit = "<Esc>",
    exec = "<CR>"
  }
}

lspconf.tsserver.setup(
  coq().lsp_ensure_capabilities(
    {
      on_attach = function(client)
        if client.config.flags then
          client.config.flags.allow_incremental_sync = true
        end
        client.resolved_capabilities.document_formatting = false
      end
    }
  )
)

map("n", "gd", "<cmd>Lspsaga lsp_finder<cr>")
map("n", "<leader>d", "<cmd>Lspsaga code_action<cr>")
map("n", "K", "<cmd>Lspsaga hover_doc<cr>")
map("n", "<leader>h", "<cmd>Lspsaga signature_help<cr>")
map("n", "gr", "<cmd>Lspsaga rename<cr>")
map("n", "<C-j>", "<cmd>Lspsaga diagnostic_jump_next<cr>")
map("n", "<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<cr>")

-- Trouble!
map("n", "<leader>t", "<cmd>TroubleToggle<cr>")

-- Completion
opt("o", "completeopt", "menu,menuone,noselect")

-- Trouble
require("trouble").setup()

-- Formatting
require("formatter").setup(
  {
    filetype = {
      lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      },
      javascript = {
        function()
          return {
            exe = "eslint_d",
            args = {"--stdin", "--fix-to-stdout", fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      },
      typescript = {
        function()
          return {
            exe = "eslint_d",
            args = {"--stdin", "--fix-to-stdout", fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      },
      javascriptreact = {
        function()
          return {
            exe = "eslint_d",
            args = {"--stdin", "--fix-to-stdout", fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      },
      typescriptreact = {
        function()
          return {
            exe = "eslint_d",
            args = {"--stdin", "--fix-to-stdout", fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      }
    }
  }
)
api.nvim_exec(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.ts,*.tsx,*.js,*.jsx,*.lua FormatWrite
augroup END
]],
  true
)
map("n", "<leader>f", "<cmd>FormatWrite<cr>")

-- The line!
local function clock()
  return " " .. os.date("%H:%M")
end

local function lsp_progress()
  local messages = vim.lsp.util.get_progress_messages()
  if #messages == 0 then
    return
  end
  local status = {}
  for _, msg in pairs(messages) do
    table.insert(status, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
  end
  local spinners = {
    "⠋",
    "⠙",
    "⠹",
    "⠸",
    "⠼",
    "⠴",
    "⠦",
    "⠧",
    "⠇",
    "⠏"
  }
  local ms = vim.loop.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  return table.concat(status, " | ") .. " " .. spinners[frame + 1]
end

cmd("autocmd User LspProgressUpdate let &ro = &ro")

require("lualine").setup(
  {
    options = {
      theme = "github",
      icons_enabled = true,
      section_separators = {"", ""},
      component_separators = {"", ""}
      -- section_separators = {"", ""},
      -- component_separators = {"", ""}
    },
    sections = {
      lualine_a = {"mode"},
      lualine_b = {"branch", "diff"},
      lualine_c = {{"diagnostics", sources = {"nvim_lsp"}}, "filename"},
      lualine_x = {},
      lualine_y = {"filetype", lsp_progress},
      lualine_z = {clock}
    },
    inactive_sections = {
      lualine_a = {"filename", "diff"},
      lualine_b = {},
      lualine_c = {}
    }
  }
)
require("bufferline").setup {
  options = {
    diagnostics = "nvim_lsp"
  }
}
map("n", "gb", "<cmd>BufferLinePick<cr>")
map("n", "<c-h>", "<cmd>BufferLineCyclePrev<cr>")
map("n", "<c-l>", "<cmd>BufferLineCycleNext<cr>")
map("n", "<c-x>", "<cmd>Bdelete<cr>")

-- Context
require "treesitter-context".setup {
  enable = true,
  throttle = true
}

-- Gotta go fast
require("hop").setup()
map("n", "<Leader>s", "<cmd>lua require'hop'.hint_words()<cr>", {})

-- More for telescope
local actions = require("telescope.actions")
require("telescope").setup {
  defaults = {
    file_ignore_patterns = { "node_modules" },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      }
    }
  },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      mappings = {
        i = {
          ["<c-x>"] = "delete_buffer"
        }
      }
    }
  }
}
map("", "<C-P>", "<cmd>Telescope find_files<cr>")
map("", "<C-G>", "<cmd>Telescope live_grep<cr>")
map("", "<C-B>", "<cmd>Telescope buffers<cr>")
