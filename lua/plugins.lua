local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Theme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {"zbirenbaum/copilot.lua"},
    {"h-hg/fcitx.nvim"},
    {"nvim-tree/nvim-tree.lua"},
    {'akinsho/toggleterm.nvim', version = "*", config = true},
    {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
    {
      'stevearc/aerial.nvim',
      opts = {},
      -- Optional dependencies
      dependencies = {
         "nvim-treesitter/nvim-treesitter",
         "nvim-tree/nvim-web-devicons"
      }
    },
    {
      "NvChad/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup({
          user_default_options = {
            names = false,      -- 识别颜色名如 red/blue
            rgb_fn = true,
            hsl_fn = true,
          },
        })
      end
    },
    -- Completions
    {
       "saghen/blink.cmp",
       dependencies = { "rafamadriz/friendly-snippets" },
       version = "*",
       opts = {
           keymap = {
               preset = "super-tab",
               ["<Up>"] = { "select_prev", "fallback" },
               ["<Down>"] = { "select_next", "fallback" },
               ["j"] = { "select_next", "fallback" },
               ["k"] = { "select_prev", "fallback" },
               ["<C-b>"] = { "scroll_documentation_up", "fallback" },
               ["<C-f>"] = { "scroll_documentation_down", "fallback" },
               ["<C-y>"] = { "show_signature", "hide_signature", "fallback" },
           },
           appearance = {
               nerd_font_variant = "mono",
           },
           sources = {
               default = { "lsp", "path", "snippets", "buffer" },
           },
           fuzzy = { implementation = "prefer_rust_with_warning" },
           completion = {
               keyword = { range = "prefix" },
               menu = {
                   draw = {
                       treesitter = { "lsp" },
                   },
               },
               trigger = { show_on_trigger_character = true },
               documentation = {
                   auto_show = true,
               },
           },
           signature = { enabled = true },
       },
       opts_extend = { "sources.default" },
    },
    {
      "init-lsp",
      dir = "~/.config/nvim",  -- 只是一个占位触发加载
      config = function()
        require("lsp")
      end,
    },
})

require("nvim-tree").setup()
require("bufferline").setup()
require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})

require("copilot").setup({
  suggestion = {
  enabled = true,
  auto_trigger = true,
  },
})

