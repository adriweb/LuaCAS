--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

local commands = {
	["diff"] = function() print("diff called") end,
	["limit"] = function() print("limit called") end,
	["sum"] = function() print("sum called") end,
	["product"] = function() print("product called") end,
	["integral"] = function() print("integral called") end
}

function checkCommand(input)
	local cmd
	for k,v in pairs(commands) do
		cmd = string.match(input,k)
		if cmd then doCommand(cmd) end
	end
end

function doCommand(cmd)
	commands[cmd]
end