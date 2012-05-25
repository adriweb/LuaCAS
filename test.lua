dofile "simple.lua"
dofile "other.lua"
dofile "tools.lua"
dofile "rpn.lua"


function lookForSimilarVariable(lesgroupes)

	local temp1,temp2
	possibleCommut = {}
	for i=1,#lesgroupes,2 do
		temp1=lesgroupes[i]:split(" ")
		temp2=lesgroupes[i+1]:split(" ")
		for _,v in pairs(temp1) do
			for _,p in pairs(temp2) do
				if v and v ~= "" and not operator[v] and possibleCommut[#possibleCommut] ~= i then 
					table.insert(possibleCommut,i)
				end
			end
		end
	end
		
	return possibleCommut
end

function generateEachCommmut(possibleCommut,rpn)
	local commutList = {}
	for _,v in pairs(possibleCommut) do
		for _,w in pairs(possibleCommut) do
			if v<w then
			for _,x in pairs(possibleCommut) do
				if x>w then
				for _,y in pairs(possibleCommut) do
					if x<y then
						table.insert(commutList,v .. w .. x .. y)
					elseif commutList[#commutList] ~= v .. w .. x then
						table.insert(commutList,v .. w .. x)
					end
				end
				elseif commutList[#commutList] ~= v .. w then
					table.insert(commutList,v .. w)
				end
			end
			elseif commutList[#commutList] ~= v then
				table.insert(commutList,v)
			end
		end
	end
	return commutList
end

function commut(lesgroupes,i,rpn)
	i = tonumber(i)
	local toCommutStart = tostring(lesgroupes[i])
	local toCommutEnd = tostring(lesgroupes[i+1])
	
	for k=1,(toCommutStart:len()+toCommutEnd:len()) do
		toCommutStart = toCommutStart:gsub("   ","  "):gsub("  "," ")
		toCommutEnd = toCommutEnd:gsub("   ","  "):gsub("  "," ")
	end
	
	print("commut : "..toCommutStart.." and "..toCommutEnd)
	
	toCommutStart = toCommutStart:split(" ")
	toCommutEnd = toCommutEnd:split(" ")
	local tempRpn = (table.concat(rpn," "):gsub("  "," ")):split(" ")

	for k=1,#toCommutStart-1 do
		table.insert(tempRpn,#toCommutEnd+#toCommutStart-1,strReplace(tempRpn[1],"  "," "))
		table.remove(tempRpn,1)
	end
	return tempRpn
end

function createPossibleRpnTable(theRpnSave,commutList)
	local listRpn = {}
	local theRpn = {}
	
	for _,v in pairs(commutList) do
			theRpn = copyTable(theRpnSave)
			local tempCommutTbl = {}
			for tmpvar=1,string.len(tostring(v)) do
				table.insert(tempCommutTbl,string.sub(tostring(v),tmpvar,tmpvar))
			end
			for _,valeur in pairs(tempCommutTbl) do
				theRpn = commut(lesgroupes,valeur,theRpn)
			end
			table.insert(listRpn,theRpn)
			theRpn = nil
	end
		return listRpn
end

local commutList = {}
local possibleCommut = {}
local listRpn = {}

rpn = {"a","b","+","c","*","a","+","d","*","b","+","c","+","b","a","*","+"}

commutList = detectCommutGroup(rpn)

print("lesgroupes = ",tblinfo2(lesgroupes))
dump("lesgroupes",lesgroupes)

listRpn = createPossibleRpnTable(rpn,commutList)
dump("listRpn",listRpn)


