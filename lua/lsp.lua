-- ~/.config/nvim/lua/config/lsp.lua
-- Neovim 内置 LSP with lspconfig + blink.cmp capabilities
local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
if not ok_lspconfig then
  vim.notify("[lsp] nvim-lspconfig not found", vim.log.levels.ERROR)
  return
end

-- 从 blink.cmp 注入能力（补全/签名/resolve 更完整）
local ok_blink, blink = pcall(require, "blink.cmp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_blink and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- 通用 on_attach：常用按键
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
  map("n", "gr", vim.lsp.buf.references, "LSP: References")
  map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation")
  map("n", "K",  vim.lsp.buf.hover, "LSP: Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
  map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "LSP: Format")
end

-- 服务器专项设置
local servers = {
  -- Lua
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        hint = { enable = true },
      },
    },
  },

  -- C/C++（clangd 来自 clang-tools）
  clangd = {
    cmd = { "clangd" }, -- 系统 PATH
    -- 可以按需启用: "--background-index","--clang-tidy"
    -- cmd = { "clangd", "--background-index" },
  },

  -- Bash
  bashls = { },

  -- SQL
  sqls = {
    -- 可选: 为不同项目提供 sqls.yml，根目录检测：
    root_dir = lspconfig.util.root_pattern(".git", "sqls.yml", "sqls.yaml"),
  },

  -- TypeScript/JavaScript
  ts_ls = {
    -- 对应 nodePackages.typescript-language-server
    -- 如果你用的是 tsserver 旧名，也可以改为 lspconfig.tsserver.setup(...)
    init_options = { hostInfo = "neovim" },
  },

  -- HTML/CSS/JSON（来自 vscode-langservers-extracted）
  html = {},
  cssls = {},
  jsonls = {},

  -- Scheme（Racket 语言服务器，兼容 Scheme 使用）
  racket_langserver = {
    -- 若 `racket-langserver` 不在 PATH，可用默认 cmd: { "racket", "-l", "racket-langserver" }
    -- cmd = { "racket", "-l", "racket-langserver" },
  },

  -- Haskell
  hls = {},

  -- Java（最小可用；进阶建议换 nvim-jdtls）
  jdtls = {
    -- 需要 Java 17+；workspace_dir 按项目创建
    cmd = { "jdtls" },
    root_dir = lspconfig.util.root_pattern("gradlew", "mvnw", ".git"),
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      -- 可在此处添加 Java 专属按键或 setup
    end,
  },
}

-- Python：在 basedpyright 与 pyright 之间自动选择（谁可执行用谁）
local has_based = (vim.fn.executable("basedpyright-langserver") == 1) or (vim.fn.executable("basedpyright") == 1)
local has_pyright = (vim.fn.executable("pyright-langserver") == 1) or (vim.fn.executable("pyright") == 1)

if has_based then
  servers.basedpyright = {
    settings = {
      basedpyright = {
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = "standard", -- 可改 "strict"
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  }
elseif has_pyright then
  servers.pyright = {
    settings = {
      pyright = { disableOrganizeImports = false },
      python = {
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = "basic", -- or "strict"
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  }
else
  -- 兜底：如果两者都没有，尝试 pylsp（python-lsp-server）
  if vim.fn.executable("pylsp") == 1 then
    servers.pylsp = {
      settings = {
        pylsp = {
          plugins = {
            pyflakes = { enabled = true },
            pycodestyle = { enabled = false },
            mccabe = { enabled = false },
            yapf = { enabled = false },
            pylint = { enabled = false },
            pylsp_mypy = { enabled = false },
          },
        },
      },
    }
  end
end

-- 统一启动
for name, cfg in pairs(servers) do
  cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
  cfg.on_attach = cfg.on_attach or on_attach
  lspconfig[name].setup(cfg)
end

-- 诊断样式（可选）
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded" },
  severity_sort = true,
})

