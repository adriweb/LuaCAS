--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
 
function getAbout()
	return [[LuaCAS v0.1b
       ----------------------------
       (C) Adrien Bertrand	
       Made in 2012.
       Thanks to Jim Bauwens
	]]
end

c_multiSpace = [[ 
 ]]
 
function getStatus()
	return colorize("showSteps : " .. tostring(showSteps) .. c_multiSpace .. "       showDebug : " .. tostring(showDebug) .. c_multiSpace .. "       showTree : " .. tostring(showTree))
end
