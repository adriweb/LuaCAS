--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
 
cmdResult = "No Command"
 
local commands = {
	["diff"] = function() cmdResult = "diff called" end,
	["limit"] = function() cmdResult = "limit called" end,
	["sum"] = function() cmdResult = "sum called" end,
	["product"] = function() cmdResult = "product called" end,
	["integral"] = function() cmdResult = "integral called" end,
	["debugON"] = function() showDebug = true cmdResult = "---Debug output enabled---" end,
	["debugOFF"] = function() showDebug = false cmdResult = "---Debug output disabled---" end,
	["stepsON"] = function() showSteps = true cmdResult = "---Steps output enabled---" end,
	["stepsOFF"] = function() showSteps = false cmdResult = "---Steps output disabled---" end
}

function checkCommand(input)
	local cmd
	for k,v in pairs(commands) do
		cmd = string.match(input,k)
		if cmd then doCommand(cmd) return true end
	end
end

function doCommand(cmd)
	commands[cmd]()
end
