-- 在 Normal 模式下，如果光标附近是 [text](path.md) 就跳转/新建 path.md
local M = {}

function link_under_cursor(line)
  local pos  = vim.api.nvim_win_get_cursor(0)      -- {row, col}
  local col  = pos[2] + 1                           -- 1-based
  if line == "" then return "" end

  -- 向左找最近的 '['
  local lb
  for i = col, 1, -1 do
    if line:sub(i, i) == "[" then lb = i; break end
  end
  if not lb then return "" end

  -- 向右找最近的 ')'
  local rp
  for i = col, #line do
    if line:sub(i, i) == ")" then rp = i; break end
  end
  if not rp or rp <= lb then return "" end

  return lb, rp
end


function M.open_md_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local lb, rp = link_under_cursor(line)
  local seg = line:sub(lb, rp)
  if seg == "" then return false end

  -- 取 () 内路径
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

function M.fix_md_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local lb, rp = link_under_cursor(line)
  local seg = line:sub(lb, rp)
  if seg == "" then return false end

  -- 取 [] 内路径
  -- 检查格式是否匹配[text]()
  -- Lua语言中，^表示字符串开头，$表示字符串结尾，%为转义字符
  if not seg or not seg:match("^%[.+%]%(%)$") then return false end

  -- 提取路径
  -- 这里会提取出([^%]]+)部分，也就是[]内的内容, 其中[^%]]为[^x](%])，即非]字符
  local text = seg:match("%[([^%]]+)%]%(%)")

  -- 将seg部分的()替换为(./text.md)
  local new_seg = seg:gsub("%(%)", "(./" .. text .. ".md)")

  -- 替换文件中的该部分
  local new_line = line:sub(1, lb - 1) .. new_seg .. line:sub(rp + 1)
  vim.api.nvim_set_current_line(new_line)
end

return M
