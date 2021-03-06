-------------------------------------
----            LuaCAS           ----
----             v1.0            ----
----                             ----
----  Adrien 'Adriweb' Bertrand  ----
----       Alexandre Gensse      ----
----             2012            ----
----                             ----
----         GPL License         ----
-------------------------------------

dofile'other.lua'
dofile'simple.lua'
dofile'wolfram.lua'

cmdResult = "No Command"
showSemiDebug = false

local commands = {
    ["showAbout"] = function(argsTable) cmdResult = c_multiSpace .. getAbout() end,
    ["showStatus"] = function(argsTable) cmdResult = getStatus() end,
    ["help"] = function(argsTable) cmdResult = getHelp() end,
    ["debugON"] = function(argsTable) showDebug = true showSemiDebug = false cmdResult = "---Debug output enabled---" end,
    ["debugOFF"] = function(argsTable) showDebug = false cmdResult = "---Debug output disabled---" end,
    ["semiDebugON"] = function(argsTable) showSemiDebug = true showDebug = false cmdResult = "---SemiDebug output enabled---" end,
    ["semiDebugOFF"] = function(argsTable) showSemiDebug = false cmdResult = "---SemiDebug output disabled---" end,
    ["treeON"] = function(argsTable) showTree = true cmdResult = "---Tree output enabled---" end,
    ["treeOFF"] = function(argsTable) showTree = false cmdResult = "---Tree output disabled---" end,
    ["colorsON"] = function(argsTable) showColors = true cmdResult = "---Colors output enabled---" end,
    ["colorsOFF"] = function(argsTable) showColors = false cmdResult = "---Colors output disabled---" end,
    ["stepsON"] = function(argsTable) showSteps = true cmdResult = "---Steps output enabled---" end,
    ["stepsOFF"] = function(argsTable) showSteps = false cmdResult = "---Steps output disabled---" end,
    ["lua"] = function(argstable) loadstring(table.concat(argstable," "))() end,
    ["wolfram"] = function(argsTable) prettyDisplay(getWolframResult(tblinfo(argsTable))) end,
	["clear"] = function(argstable) os.execute("cls") end
}

function checkCommand(input)
    local cmd
    for k, v in pairs(commands) do
        cmd = string.match(input, k)
        if cmd then
           	outputStack = {}
        	local _, tmp = string.find(input, cmd)
        	doCommand(cmd, input:sub(2 + tmp))
        	return true
        end
    end
end

function doCommand(cmd, input)
    commands[cmd](input:split())
    if cmdResult ~= "No Command" then endCommand(cmdResult) end
    checkCommand(input)
end

function endCommand(cmdResult)
    prettyDisplay(cmdResult)
    cmdResult = ""
end

function getHelp()
    local theString = "List of available commands (besides basic math input) : "
    for cmd, _ in pairs(commands) do
        theString = theString .. c_multiSpace .. tostring(cmd)
    end
    return theString
end
