vim.keymap.set('n', '<C-s>', ':w<CR>', {silent = true})
vim.keymap.set('i', '<C-s>', '<ESC>:w<CR>a', {silent = true})

vim.keymap.set('v', '<C-c>', 'y', {silent = true})
vim.keymap.set('i', '<C-v>', '<ESC>p', {silent = true})

vim.keymap.set('n', '<C-h>', '<C-w>h', {silent = true})
vim.keymap.set('n', '<C-j>', '<C-w>j', {silent = true})
vim.keymap.set('n', '<C-k>', '<C-w>k', {silent = true})
vim.keymap.set('n', '<C-l>', '<C-w>l', {silent = true})

vim.keymap.set('n', 'gt', ':NvimTreeToggle<CR>', {silent = true})

vim.keymap.set('n', 'gp', ':BufferLinePick<CR>', {silent = true})
vim.keymap.set('n', 'gP', ':BufferLinePickClose<CR>', {silent = true})

vim.keymap.set('n', 'gl', ':BufferLineCycleNext<CR>', {silent = true})
vim.keymap.set('n', 'gh', ':BufferLineCyclePrev<CR>', {silent = true})

vim.keymap.set('n', 'gx', ':ToggleTerm<CR>', {silent = true})

vim.keymap.set("n", "gi", vim.diagnostic.open_float, {silent = true})

vim.keymap.set("n", "ga", "<cmd>AerialToggle!<CR>")

-- Kiwi & Nvim-Tree
local VAULT = vim.fs.normalize(vim.fn.expand("~/Notes"))
local api = require("nvim-tree.api")

vim.keymap.set("n", "<leader>ww", function()
  require("kiwi").open_wiki_index()

  vim.schedule(function()
    if not api.tree.is_visible() then
      api.tree.open()
    end
    api.tree.change_root(VAULT)
    api.tree.find_file({ open = false, focus = false, buf = 0 })
  end)
end, { desc = "Open Kiwi index and sync NvimTree root" })
