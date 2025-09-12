-- 在 Normal 模式下，如果光标附近是 [text](path.md) 就跳转/新建 path.md
local M = {}

function M.open_md_link_under_cursor()
  local pos  = vim.api.nvim_win_get_cursor(0)      -- {row, col}
  local col  = pos[2] + 1                           -- 1-based
  local line = vim.api.nvim_get_current_line()
  if line == "" then return false end

  -- 向左找最近的 '['
  local lb
  for i = col, 1, -1 do
    if line:sub(i, i) == "[" then lb = i; break end
  end
  if not lb then return false end

  -- 向右找最近的 ')'
  local rp
  for i = col, #line do
    if line:sub(i, i) == ")" then rp = i; break end
  end
  if not rp or rp <= lb then return false end

  -- 取 () 内路径
  local seg  = line:sub(lb, rp)
  local path = seg:match("%b[]%(([^)]+)%)")
  if not path or not path:match("%.md$") then return false end

  -- 解析为绝对路径（相对按当前缓冲区目录）
  local target
  if path:sub(1,1) == "/" or path:sub(1,1) == "~" then
    target = vim.fn.expand(path)
  else
    target = vim.fn.expand("%:p:h") .. "/" .. path
  end
  target = vim.fn.fnamemodify(target, ":p")

  -- 确保目录存在
  local dir = vim.fn.fnamemodify(target, ":h")
  if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end

  -- 跳转/新建
  vim.cmd.edit(vim.fn.fnameescape(target))
  return true
end

return M
