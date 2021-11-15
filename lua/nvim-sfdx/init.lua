--TODO get source root from project.json
--TODO get default username
--TODO Run Local Tests
--TODO Run Class Tests
--TODO build quickfix list from test results
--TODO Refresh sobject definitions
--TODO Attach debugger in split/tmux session

local function i(obj)
  print(vim.inspect(obj))
end

local function deploy(metadata, username)
  local cmd = 'sfdx force:source:deploy '
  if (metadata~=nil)
    then
      cmd = cmd .. ' -m ' .. metadata
    else
      local wd = vim.fn.getcwd()
      cmd = cmd .. ' -x ' .. wd .. '/package.xml'
  end
  if (username~=nil)
    then
      cmd = cmd .. ' -u ' .. username
  end

  cmd = cmd .. ' --json'

  local handle = io.popen(cmd)
  local result = handle:read("*a")
  local deserialized = vim.fn.json_decode(result)
  local errors = deserialized.result.details.componentFailures
  i(deserialized)
  local qflist = {}
  for _, v in ipairs(errors)
    do
      local fn = 'force-app/main/default/' .. v.fileName
      local qf = {filename = fn, lnum = v.lineNumber, col = v.columnNumber, text = v.problem }
      table.insert(qflist, qf)
  end
  vim.fn.setqflist(qflist)
  vim.api.nvim_command("botright copen")
  handle.close()
end

local function debug(username, debug_only)
  local cmd = 'sfdx force:apex:log:tail'
  if (username~=nil)
    then
      cmd = cmd .. '-u ' .. username
  end
  if (debug_only)
    then
    cmd = cmd .. ' | rg USER_DEBUG'
  end
  vim.fn.termopen(cmd)
end

return {
  deploy = deploy,
  debug = debug
}
