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

dofile"rpn.lua"
dofile"tools.lua"

function getAbout()
    return [[╔----------------------------╗
║  LuaCAS 1.0 · GPL License  ║
╠----------------------------╢
║  (C) 2012 Adrien Bertrand  ║
║    and Alexandre Gensse.   ║
║ Many Thanks to Jim Bauwens ║
╚----------------------------╝
	]]
end

c_multiSpace = [[
  ]]

function getStatus()
    return colorize("showSteps : " .. tostring(showSteps) .. c_multiSpace .. "       showDebug : " .. tostring(showDebug) .. c_multiSpace .. "       showTree : " .. tostring(showTree).. "       showColors : " .. tostring(showColors))
end

showDebug = false
showTree = false
showSteps = false

input = ""
rawResult = "NoResult"
factResult = "NoFactResult"
chgFlag = 0


function findNextPlus(rpn)
    for k, v in ipairs(rpn) do
        if v == "+" or v == "+ " or v == " +" or v == " + " then return k end
    end
    return 0
end

function findNextOp(rpn)
    for k, v in pairs(rpn) do
        if operator[v] then return k end
    end
    return 0 -- probleme....
end

function getNextOp(rpn)
    for k, v in pairs(rpn) do
        if operator[v] then return v end
    end
    return nil -- probleme....
end

function afficheTable(tbl)
    local str = ""
    for _, v in pairs(tbl) do
        str = str .. tblinfo(v)
    end
end

function resort(tbl)
    local newTable = {}
    for _, value in pairs(tbl) do
        table.insert(newTable, value)
    end
    return newTable
end
