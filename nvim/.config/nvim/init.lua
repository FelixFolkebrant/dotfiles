-- Enable clipboard with unnamedplus
vim.o.clipboard = "unnamedplus"


vim.o.number = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4


-- Bootstrap lazy.nvim if it's not installed
local lazypath = vim.fn.stdpath('data')..'/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- THEME 
-- THEME 
require("lazy").setup({
  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    name = "arctic",
    branch = "main",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme arctic")

      -- Set transparent background for UI elements without touching text color
      vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")           -- Normal background
      vim.cmd("highlight NormalNC guibg=NONE ctermbg=NONE")         -- Non-current window background
      vim.cmd("highlight StatusLine guibg=NONE ctermbg=NONE")       -- Status line background
      vim.cmd("highlight StatusLineNC guibg=NONE ctermbg=NONE")     -- Non-current status line background
      vim.cmd("highlight VertSplit guibg=NONE ctermbg=NONE")        -- Vertical split background
      vim.cmd("highlight EndOfBuffer guibg=NONE ctermbg=NONE")      -- End of buffer background

      -- Ensure transparent background for popups, without affecting foreground
      vim.cmd("highlight Pmenu guibg=NONE ctermbg=NONE")            -- Popup menu background
      vim.cmd("highlight PmenuSbar guibg=NONE ctermbg=NONE")        -- Popup menu scrollbar background
      vim.cmd("highlight PmenuSel guibg=NONE ctermbg=NONE")         -- Popup menu selection background
    end,
  },
})

-- Set transparent background and apply the theme
vim.cmd("colorscheme arctic")  -- Set the colorscheme to Arctic
vim.o.termguicolors = true     -- Enable true colors


-- Set transparent background for Catppuccin theme

-- Automatically quit without warning if no changes are made
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.cmd("set modifiable")
  end
})

-- Allow :q to exit without warning if no changes are made
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.fn.winnr('$') == 1 and not vim.bo.modified then
      vim.cmd("q!")
    end
  end
})

