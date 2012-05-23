--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
 
dofile "rpn.lua"
dofile "tools.lua"
 
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


showDebug = false
showTree = false
showSteps = false

input = ""
rawResult = "NoResult"
factResult = "NoFactResult"
chgFlag = 0


function goTest(rpn)
			
			------- test
			print("   TEST START")
					
			rpn = rpn:split(" ")
			rpngroupe = {}
			lesgroupes = {}
			nbrDeGroupes = 2
			cptgrp = 1
			i = 1
			while i > 0 do
				i = findNextPlus(rpn)
				compteur = 2
				while compteur ~= 0 do
					i = i-1
					if i > 0 then
						--print("------------------------------------------ compteur = " .. compteur)
						--print("------------------------------------------ cptgrp = " .. cptgrp)
						--print("avant :" .. (lesgroupes[cptgrp] or ""), rpn[i])
						
						if rpn[i] == "+" then -- il a normalement déjà été traité
							lesgroupes[cptgrp] = lesgroupes[cptgrp-2] .. lesgroupes[cptgrp-1] .. "+ " .. (lesgroupes[cptgrp] or "")
							local lesgroupestables1 = lesgroupes[cptgrp-2]:split(" ")
							local lesgroupestables2 = lesgroupes[cptgrp-1]:split(" ")
							i = i - #lesgroupestables1 - #lesgroupestables2
						else
							lesgroupes[cptgrp] = rpn[i] .. " " .. (lesgroupes[cptgrp] or "")
							--print("apres :" .. lesgroupes[cptgrp], rpn[i])
							if operator[rpn[i]] then
								compteur = compteur+2
							end
						end
					end
					if rpn[i+1] == "+" then
						--compteur = compteur - 1
					end
					compteur = compteur - 1
					if compteur == 1 then
						cptgrp = cptgrp + 1
						if i~=1 then 
							if operator[rpn[i-1]] then
								compteur = compteur + 1
							end
						end
					end
				end
				cptgrp = cptgrp + 1
				print(tblinfo(rpn))
				for tmp=1,findNextPlus(rpn) do
					table.remove(rpn,1)
				end
				print(tblinfo(rpn))
				
			--[[	while getNextOp(rpn) ~= "+" and getNextOp(rpn) do
					temp = (lesgroupes[nbrDeGroupes-1] or "") .. (lesgroupes[nbrDeGroupes] or "")
					if getNextOp(rpn) ~= "+" and getNextOp(rpn) and not operator(rpn[findNextOp(rpn)+1]) then
						for k=1,findNextOp(rpn) do
							temp = temp .. rpn[k] .. " "
						end
					end
					
					for tmp=1,findNextOp(rpn) do
						table.remove(rpn,1)
					end

				end
			]]--
			
				lesgroupes = resort(lesgroupes)

				lesgroupes[nbrDeGroupes-1],lesgroupes[nbrDeGroupes] = lesgroupes[nbrDeGroupes],lesgroupes[nbrDeGroupes-1]
				gr = (lesgroupes[nbrDeGroupes] or "niiil") .. (lesgroupes[nbrDeGroupes-1] or "nooool") .. "+ "
				table.insert(rpn,1,gr)
				
				i = findNextPlus(rpn) -- RHAAAAA
					
				nbrDeGroupes = nbrDeGroupes + 2
			end
			
			for k,v in pairs(lesgroupes) do
				print(k,v)
			end
			print("------")
			print("rpn = " .. tblinfo(rpn))
			print("   TEST END")
			
			------- test
end

function findNextPlus(rpn)
	for k,v in ipairs(rpn) do
		if v == "+" then return k end
	end
	return 0
end

function findNextOp(rpn)
	for k,v in pairs(rpn) do
		if operator[v] then return k end
	end
	return 0 -- probleme....
end

function getNextOp(rpn)
	for k,v in pairs(rpn) do
		if operator[v] then return v end
	end
	return nil -- probleme....
end

function afficheTable(tbl)
	local str = ""
	for _,v in pairs(tbl) do
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

function badresort(table)
	local indexes = {}
	for k,_ in pairs(table) do
	    indexes[#indexes+1] = k
	end
	local newTable = {}
	for i=1,#indexes do
		if table[indexes[i]] then
			newTable[#newTable+1] = table[indexes[i]]
		end
	end
	return newTable
end