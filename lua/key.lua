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

vim.keymap.set("n", "ga", "<cmd>AerialToggle!<CR>")

vim.keymap.set("n", "<CR>", function()
  if not require("mdlink").open_md_link_under_cursor() then
    local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
    vim.api.nvim_feedkeys(cr, "n", false)
  end
end, { noremap = true, silent = true })
