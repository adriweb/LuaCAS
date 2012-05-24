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
				print("v="..v,"p="..p,"i="..i)
				if v and v == p and v ~= "" and not operator[v] and possibleCommut[#possibleCommut] ~= i then 
					print("bouh et i="..i)
					table.insert(possibleCommut,i)
				end
			end
		end
	
	end
	return possibleCommut
	
end


function generateEachCommmut(possibleCommut,rpn)

print("here")


	local commutList = {}
	for _,v in pairs(possibleCommut) do
		for _,w in pairs(possibleCommut) do
			if v>w then
			for _,x in pairs(possibleCommut) do
				if x<w then
				for _,y in pairs(possibleCommut) do
					if x>y then
						print ("v=" .. v,"w=" .. w,"x=" .. x,"y=" .. y)
						table.insert(commutList,v .. w .. x .. y)
					elseif commutList[#commutList] ~= v .. w .. x then
						print ("v=" .. v,"w=" .. w,"x=" .. x)
						table.insert(commutList,v .. w .. x)
					end
				end
				elseif commutList[#commutList] ~= v .. w then
					print ("v=" .. v,"w=" .. w)
					table.insert(commutList,v .. w)
				end
			end
			elseif commutList[#commutList] ~= v then
				print ("v=" .. v)
				table.insert(commutList,v)
			end
		end
	end
	return commutList
end

function commut(lesgroupes,i)
	
	local toCommutStart = tostring(lesgroupes[i])
	local toCommutEnd = tostring(lesgroupes[i+1])
	
	for k=1,(#lesgroupes[i]+#lesgroupes[i+1]) do
		toCommutStart = toCommutStart:gsub("  "," ")
		toCommutEnd = toCommutEnd:gsub("  "," ")
	end
	
	toCommutStart = toCommutStart:split(" ")
	toCommutEnd = toCommutEnd:split(" ")
	
	local tempRpn = (table.concat(rpn," "):gsub("  "," ")):split(" ")

print("toCommutStart = ",tblinfo(toCommutStart))
print("toCommutEnd = ",tblinfo(toCommutEnd))
print("tempRpn = ",tblinfo(tempRpn))


	for k=1,#toCommutStart-1 do
		table.insert(tempRpn,#toCommutEnd+#toCommutStart-1,tempRpn[1])
		table.remove(tempRpn,1)
		print("tempRpn = ",tblinfo(tempRpn))

	end
	return tempRpn
end

local commutList = {}
local possibleCommut = {}
rpn = {"a","b","+","c","*","a","+","d","*","b","+","c","+","b","a","*","+"}

detectCommutGroup(rpn)
possibleCommut = lookForSimilarVariable(lesgroupes)
commutList = generateEachCommmut(possibleCommut,rpn)

print("lesgroupes = ",tblinfo(lesgroupes))
dump("lesgroupes",lesgroupes)

print("possibleCommut = ",tblinfo(possibleCommut))

dump("commutList",commutList)


