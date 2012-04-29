--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
 
function getAbout()
	return [[╔----------------------------╗
║ LuaCAS v0.2b · GPL License ║
╠----------------------------╢
║  (C) 2012 Adrien Bertrand  ║
║ Many Thanks to Jim Bauwens ║
╚----------------------------╝
	]]
end

c_multiSpace = [[ 
 ]]
 
function getStatus()
	return colorize("showSteps : " .. tostring(showSteps) .. c_multiSpace .. "       showDebug : " .. tostring(showDebug) .. c_multiSpace .. "       showTree : " .. tostring(showTree))
end
