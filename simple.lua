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
	local pos	= 0
	local n1, n2, op
	
	while true do 
		pos	= pos + 1
		n1	= tonumber(rpn[pos-2]) -- isNumeric(rpn[pos-2]) and tonumber(rpn[pos-2]) or rpn[pos-2]
		n2	= tonumber(rpn[pos-1]) -- isNumeric(rpn[pos-1]) and tonumber(rpn[pos-1]) or rpn[pos-1]
		op	= rpn[pos]
		--if strType(op)=="operator" then print(n1,op,n2) end
		if pos<=#rpn then
			if n1 and n2 and operator[op] then
				local sim, a, b	= true
				if op == "/" then
					sim, a, b	= div(n1, n2)
					if not sim then 
						rpn[pos-2] = a
						rpn[pos-1] = b
					end
				end
				
				if sim then
					local solution = operator[op][3](n1, n2)
					for i=1,3 do table.remove(rpn, pos-2) end
					table.insert(rpn, pos-2, solution)
					return simplify(rpn)
				end
			end
		else
			break
		end
		
	end
	
	return rpn
end

function sortgroup(rpn, posa, posb)
	local sorttable	= {}
	table.insert(sorttable, rpn[posa])
	table.insert(sorttable, rpn[posa+1])
	
	for i=posa+3, posb, 2 do
		table.insert(sorttable, rpn[i])
	end
	table.sort(sorttable)
	
	rpn[posa]	= sorttable[1]
	rpn[posa+1]	= sorttable[2]
	local j	= 2
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
	local c, o, i
	for i=pos+3, len-1, 2 do
		c	= rpn[i]
		o	= rpn[i+1]
		
		if o ~= ro then
			return i-1
		end 
	end
	
	return len
end

function simpleit(rpn)

	local len	= #rpn
	local cgroup	= {}
	local breakuntil	= 0
	local i
	
	for i=1, len-2 do 
		if breakuntil>i then 
			break
		end
		
		local a	= rpn[i]
		local b	= rpn[i+1]
		local o	= rpn[i+2]
		if not operator[a] and not operator[b] and operator[o] then -- this means for example "3 5 *"
			local posb	= findgroup(rpn, i, o)
			sortgroup(rpn, i, posb)
			breakuntil	= posb + 1
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



