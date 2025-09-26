-- ~/.config/nvim/lua/config/lsp.lua
-- 纯 vim.lsp.config（Neovim 0.11+）
-- 补全能力对接 blink.cmp

-- === blink.cmp 能力 ===
local ok_blink, blink = pcall(require, "blink.cmp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_blink and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- === root_pattern：用 vim.fs.find 实现 ===
local function root_pattern(...)
  local patterns = { ... }
  return function(startpath)
    local path = startpath
    if type(path) ~= "string" or path == "" then
      local name = vim.api.nvim_buf_get_name(0)
      path = (name ~= "" and name) or vim.uv.cwd()
    end
    path = vim.fs.dirname(path)
    local found = vim.fs.find(patterns, { path = path, upward = true, type = "file" })
    return (found and found[1]) and vim.fs.dirname(found[1]) or nil
  end
end

-- === on_attach：常用键位 ===
local function on_attach(_, bufnr)
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

-- === 轻量“框架”：把服务器注册到 vim.lsp.config 并设置 FileType 自动启动 ===
local function register_server(name, default_config)
  local M = {}
  M.default_config = default_config
  function M.setup(user_cfg)
    local cfg = vim.tbl_deep_extend("force", default_config, user_cfg or {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = cfg.filetypes or {},
      group = vim.api.nvim_create_augroup("lsp_auto_start_" .. name, { clear = true }),
      callback = function(ev)
        -- 计算 root_dir
        local bufname = vim.api.nvim_buf_get_name(ev.buf)
        local root = (type(cfg.root_dir) == "function") and cfg.root_dir(bufname) or cfg.root_dir
        if not root and cfg.single_file_support ~= false then
          root = vim.fs.dirname(bufname ~= "" and bufname or vim.uv.cwd())
        end
        if not root then return end

        vim.lsp.start({
          name = name,
          cmd = cfg.cmd,
          root_dir = root,
          settings = cfg.settings,
          capabilities = cfg.capabilities,
          on_attach = function(client, bufnr)
            if cfg.on_attach then cfg.on_attach(client, bufnr) end
          end,
          init_options = cfg.init_options,
          single_file_support = cfg.single_file_support ~= false,
        })
      end,
    })
  end
  vim.lsp.config[name] = M
end

----------------------------------------------------------------
-- === 定义各语言最小可用 default_config（cmd 需在 PATH 中） ===
----------------------------------------------------------------

-- Lua (lua-language-server)
register_server("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_dir = root_pattern(".git", ".luarc.json", ".luarc.jsonc"),
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- C/C++ (clangd)
register_server("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Bash (bash-language-server)
register_server("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_dir = root_pattern(".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- SQL (sqls)
register_server("sqls", {
  cmd = { "sqls" },
  filetypes = { "sql" },
  root_dir = root_pattern("sqls.yml", "sqls.yaml", ".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- TypeScript/JavaScript (typescript-language-server)
register_server("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx", "mjs", "cjs" },
  root_dir = root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
  init_options = { hostInfo = "neovim" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- HTML
register_server("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_dir = root_pattern(".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- CSS
register_server("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_dir = root_pattern(".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- JSON
register_server("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_dir = root_pattern(".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Scheme / Racket
register_server("racket_langserver", {
  cmd = { "racket", "-l", "racket-langserver" },
  filetypes = { "racket", "scheme" },
  root_dir = root_pattern(".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Haskell (haskell-language-server)
register_server("hls", {
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  filetypes = { "haskell", "lhaskell" },
  root_dir = root_pattern("hie.yaml", "stack.yaml", "cabal.project", ".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Java (jdtls) —— 仅最小可用；复杂项目请用 nvim-jdtls
register_server("jdtls", {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_dir = root_pattern("gradlew", "mvnw", ".git"),
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Python：basedpyright > pyright > pylsp（三选一注册）
local has_based = (vim.fn.executable("basedpyright-langserver") == 1) or (vim.fn.executable("basedpyright") == 1)
local has_pyright = (vim.fn.executable("pyright-langserver") == 1) or (vim.fn.executable("pyright") == 1)

if has_based then
  register_server("basedpyright", {
    cmd = (vim.fn.executable("basedpyright-langserver") == 1)
      and { "basedpyright-langserver", "--stdio" }
      or  { "basedpyright", "--stdio" },
    filetypes = { "python" },
    root_dir = root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
    settings = {
      basedpyright = {
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = "standard",
          diagnosticMode = "openFilesOnly",
        },
      },
    },
    capabilities = capabilities,
    on_attach = on_attach,
  })
elseif has_pyright then
  register_server("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_dir = root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git"),
    settings = {
      pyright = { disableOrganizeImports = false },
      python = {
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = "basic",
          diagnosticMode = "openFilesOnly",
        },
      },
    },
    capabilities = capabilities,
    on_attach = on_attach,
  })
elseif vim.fn.executable("pylsp") == 1 then
  register_server("pylsp", {
    cmd = { "pylsp" },
    filetypes = { "python" },
    root_dir = root_pattern(".git"),
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
    capabilities = capabilities,
    on_attach = on_attach,
  })
end

----------------------------------------------------------------
-- === 你的“个性化覆盖”区：按需传入 settings/cmd 等 ===
----------------------------------------------------------------
local overrides = {
  -- 示例：lua_ls/hls 等有额外需求时写在这
  -- lua_ls = { settings = { Lua = { hint = { enable = true } } } },
}

-- 按服务器名执行 setup（会创建 FileType 自动启动）
for name, mod in pairs(vim.lsp.config) do
  if type(mod) == "table" and type(mod.setup) == "function" then
    mod.setup(overrides[name])
  end
end

-- === 诊断样式 ===
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded" },
  severity_sort = true,
})

