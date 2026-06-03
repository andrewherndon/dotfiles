-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit terminal mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Toggle floating terminal with backtick
vim.keymap.set({'n', 't'}, '`', '<cmd>ToggleTerm direction=float<CR>', { desc = "Toggle floating terminal" })

-- VimTeX keymaps (only set for tex files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Compilation
    vim.keymap.set("n", "<localleader>ll", "<cmd>VimtexCompile<CR>", { buffer = true, desc = "VimTeX Compile" })
    vim.keymap.set("n", "<localleader>lc", "<cmd>VimtexClean<CR>", { buffer = true, desc = "VimTeX Clean" })
    vim.keymap.set("n", "<localleader>lC", "<cmd>VimtexClean!<CR>", { buffer = true, desc = "VimTeX Clean All" })

    -- Viewing
    vim.keymap.set("n", "<localleader>lv", "<cmd>VimtexView<CR>", { buffer = true, desc = "VimTeX View" })

    -- Navigation
    vim.keymap.set("n", "<localleader>lt", "<cmd>VimtexTocToggle<CR>", { buffer = true, desc = "VimTeX Toggle TOC" })
    vim.keymap.set("n", "<localleader>lq", "<cmd>VimtexLog<CR>", { buffer = true, desc = "VimTeX Log" })

    -- Status
    vim.keymap.set("n", "<localleader>ls", "<cmd>VimtexStatus<CR>", { buffer = true, desc = "VimTeX Status" })
    vim.keymap.set("n", "<localleader>li", "<cmd>VimtexInfo<CR>", { buffer = true, desc = "VimTeX Info" })
  end,
})
