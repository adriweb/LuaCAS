--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
-- Parts also by Jim Bauwens

function areNumeric(a,b)
	return isNumeric(a) and isNumeric(b)
end

function isClean(n)
	return math.floor(n) == n
end

function div(a,b)
	if areNumeric(a,b) then
		local sol	= a/b
		if isClean(sol) then
			return true, sol
		elseif isClean(a) and isClean(b) then
			for i=math.min(a, b), 2, -1 do
				if isClean(a/i) and isClean(b/i) then
					a=a/i
					b=b/i
					break
				end
			end 
			return false, a, b
		else
			return false, a, b
		end
	end
end	

function simplify(rpn)
	sortit(rpn)
	return rpn
end

function creategroup(datatable, operator, startgroup)
	local group	=	{}
	
	group[1]	= startgroup or table.remove(datatable, 1)

	for _, value in ipairs(datatable) do
		table.insert(group, tostring(value))	-- tostring to be sure all data is in strings when we put it back in the RPN table
		table.insert(group, operator)
	end
	
	return group
end

function simpgroup(rpn, posa, posb, o, startgroup)
	local len	= #rpn
	local n	= posb-posa		-- The length of the RPN group we are handling
	local datatable	= {}
	
	local d
	for i=posa, posb do
		d	= table.remove(rpn, posa) -- Remove the whole group from the RPN table
		
		if not operator[d] then 
			table.insert(datatable, d)
		end
	end
	
	table.sort(datatable)	-- sort the datatable
	
	local n1, n2
	if o ~= "/" then
		while tonumber(datatable[1]) and tonumber(datatable[2]) do
			datatable[1]	= operator[o][3](datatable[1], table.remove(datatable, 2))
		end
	end
	
	local group	= creategroup(datatable, o, startgroup)
	
	for k, value in ipairs(group) do
		table.insert(rpn, posa+k-1, value)
	end
	
	if len<#rpn then 
		return true
	end
end

function sortgroup(rpn, posa, posb, startgroup)
	local sorttable	= {}
	if startgroup then
		table.insert(sorttable, rpn[posa])
	end
	
	table.insert(sorttable, rpn[posa+1])
	for i=posa+3, posb, 2 do
		table.insert(sorttable, rpn[i])
	end
	table.sort(sorttable)


	local j	= 1
	if startgroup then	
		rpn[posa]	= sorttable[j]
		j	= j+1
	end
	
	rpn[posa+1]	= sorttable[j]
	
	for i=posa+3, posb, 2 do
		j	= j+1
		rpn[i]	= sorttable[j]
	end	
end

function findgroup(rpn, pos, ro)
	local len	= #rpn
	local posa = pos
	
	if len<pos+3 then
		return pos+2
	end
	
	local c, o
	local out	= pos + 2
	for i=pos+3, len-1, 2 do
		out	= i
		c	= rpn[i]
		o	= rpn[i+1]
		if o ~= ro then
			return i-1
		end 
	end

	return out
end

function sortit(rpn)
	mstable(rpn)
	local len	= #rpn
	local cgroup	= {}
	local breakuntil	= 0
	local sortgroup
	
	for i=1, len-2 do 
		if breakuntil>i then 
			break
		end
		
		local a	= rpn[i]
		local b	= rpn[i+1]
		local o	= rpn[i+2]
		if not operator[b] and operator[o] then -- this means for example "5 5 *"
			local posb	= findgroup(rpn, i, o)
			local done	= simpgroup(rpn, i, posb, o, operator[a] and a)
			if done then
				sortit(rpn)
				break
			end
		end
	end
	
	return rpn
end

function cc(tbl)
	out	= ""
	for k,v in pairs(tbl) do
		out = out .. v .. " "
	end
	return out
end

function strType(str)
	if not str then return nil end
	if isNumeric(str) then return "numeric" end
	if string.find("*-+/^",str) then return "operator" end
	if string.find(" ",str) then return "blank" end
	-- if string.find("sin",str) then return "function" end    --> do all other cases
end



