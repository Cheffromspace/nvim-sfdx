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

local function deploy(metadata, username, checkonly, runlocal)
  local cmd = 'sfdx force:source:deploy '
  if (metadata)
    then
      cmd = cmd .. ' -m ' .. metadata
    else
      local wd = vim.fn.getcwd()
      cmd = cmd .. ' -x ' .. wd .. '/manifest/package.xml'
  end
  if (username~=nil)
    then
      cmd = cmd .. ' -u ' .. username
  end
  if (checkonly)
    then
      cmd = cmd .. ' -c '
  end
  if (runlocal)
    then
      cmd = cmd .. ' -l RunLocalTests'
    end


  cmd = cmd .. ' --json'

  local handle = io.popen(cmd)
  local result = handle:read("*a")
  -- i(result)
  local deserialized = vim.fn.json_decode(result)
  -- i(deserialized)
  local deploymentResponse = deserialized.result.deployedSource
  local qflist = {}
  for _, v in ipairs(deploymentResponse)
    do
    if v.state =='Failed'
      then
      local qf = {filename = v.filePath, lnum = v.lineNumber, col = v.columnNumber, text = v.error }
      table.insert(qflist, qf)
    end
  end
  if next(qflist) ~= nil
    then
    vim.fn.setqflist(qflist)
    vim.api.nvim_command("botright copen")
  end
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
