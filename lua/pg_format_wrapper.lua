-- Post-processing fixes for pg_format output
-- Used by conform.nvim as a custom formatter

local M = {}

--- Fix function calls where multiple args are crammed onto one line.
--- Also handles case where pg_format already wrapped but left first arg
--- on the same line as the opening paren.
---@param lines string[]
---@param indent string base indent (spaces)
---@return string[]
function M.wrap_function_args(lines, indent)
  local result = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]

    -- Match: <indent><name>(arg, arg, ...) possibly ending with ); or $$
    -- Only trigger if there are 2+ commas (3+ args) on the line
    local pre, fname, args_str, close = line:match '^(%s*)(%S+%()(.*)(%)%s*;?)%s*$'
    if not pre or not fname then
      -- Try matching fn call that doesn't close on same line (e.g. $$ continues)
      pre, fname, args_str = line:match '^(%s*)(%S+%()(.*%$%$.*)$'
      if pre and fname then close = nil end
    end

    if fname and args_str then
      -- Count commas outside of $$ blocks and strings
      local comma_count = 0
      local in_dollar = false
      local in_quote = false
      local ci = 1
      while ci <= #args_str do
        local ch = args_str:sub(ci, ci)
        if args_str:sub(ci, ci + 1) == '$$' then
          in_dollar = not in_dollar
          ci = ci + 2
        elseif ch == "'" and not in_dollar then
          in_quote = not in_quote
          ci = ci + 1
        else
          if ch == ',' and not in_dollar and not in_quote then comma_count = comma_count + 1 end
          ci = ci + 1
        end
      end

      if comma_count >= 2 then
        -- Split args respecting $$ and quotes
        local args = {}
        local current = ''
        local d_quote = false
        local s_quote = false
        local j = 1
        while j <= #args_str do
          local ch = args_str:sub(j, j)
          if args_str:sub(j, j + 1) == '$$' then
            d_quote = not d_quote
            current = current .. '$$'
            j = j + 2
          elseif ch == "'" and not d_quote then
            s_quote = not s_quote
            current = current .. ch
            j = j + 1
          elseif ch == ',' and not d_quote and not s_quote then
            table.insert(args, vim.trim(current))
            current = ''
            j = j + 1
          else
            current = current .. ch
            j = j + 1
          end
        end
        if current ~= '' then
          -- Last arg might include the closing paren
          local last = vim.trim(current)
          if not close then
            -- Check if last arg ends with );
            local arg_part, close_part = last:match '^(.-)(%s*%)%s*;?)%s*$'
            if arg_part and close_part and close_part ~= '' then
              last = vim.trim(arg_part)
              close = close_part
            end
          end
          table.insert(args, last)
        end

        -- Rebuild with each arg on its own line
        local arg_indent = pre .. indent
        table.insert(result, pre .. fname)
        for ai, arg in ipairs(args) do
          local suffix = ai < #args and ',' or ''
          table.insert(result, arg_indent .. arg .. suffix)
        end
        if close then table.insert(result, pre .. close) end
        i = i + 1
        goto continue
      end
    end

    -- Handle: fn_name(first_arg, -- comment
    --           next_arg, ...
    -- where pg_format already wrapped but first arg is on the fn line
    local pre2, fname2, first_arg = line:match "^(%s*)(%S+%()(%s*'.+)$"
    if pre2 and fname2 then
      -- Check if next lines are continuation args (indented, start with quote/$$)
      local has_continuation = false
      if i < #lines then
        local next_line = lines[i + 1]
        local next_trimmed = vim.trim(next_line)
        if next_trimmed:match "^'" or next_trimmed:match '^%$%$' then has_continuation = true end
      end
      if has_continuation then
        local arg_indent = pre2 .. indent
        table.insert(result, pre2 .. fname2)
        table.insert(result, arg_indent .. vim.trim(first_arg))
        i = i + 1
        goto continue
      end
    end

    table.insert(result, line)
    i = i + 1
    ::continue::
  end
  return result
end

--- Fix pg_format breaking `TEXT DEFAULT` across two lines
---@param lines string[]
---@return string[]
function M.fix_split_defaults(lines)
  local result = {}
  local i = 1
  while i <= #lines do
    if i < #lines then
      local next_trimmed = vim.trim(lines[i + 1])
      -- If next line starts with DEFAULT and current line ends with a type name
      -- (not a comment or other statement)
      if next_trimmed:match '^DEFAULT%s' and lines[i]:match '[%w_]+%s*$' and not lines[i]:match '^%s*%-%-' then
        result[#result + 1] = lines[i] .. ' ' .. next_trimmed
        i = i + 2
        goto continue
      end
    end
    result[#result + 1] = lines[i]
    i = i + 1
    ::continue::
  end
  return result
end

--- Restore space before ( for DDL keywords that --no-space-function strips.
--- e.g. CREATE TABLE name( → CREATE TABLE name (
---@param lines string[]
---@return string[]
function M.fix_ddl_parens(lines)
  -- DDL keywords where --no-space-function incorrectly strips space before (
  local ddl_patterns = {
    '(CREATE%s+TABLE%s+.-[%w_"]+)(%(%s*)$', -- CREATE TABLE name(
    '(CREATE%s+TABLE%s+.-[%w_"]+)(%()', -- CREATE TABLE name(col
    '(INSERT%s+INTO%s+[%w_%."]+)(%()', -- INSERT INTO name(cols)
    '(VALUES)(%()', -- VALUES(...)
  }
  local result = {}
  for _, line in ipairs(lines) do
    for _, pat in ipairs(ddl_patterns) do
      if line:match(pat) then
        line = line:gsub(pat, '%1 %2', 1)
        break
      end
    end
    result[#result + 1] = line
  end
  return result
end

return M
