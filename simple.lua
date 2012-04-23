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

needReSimplify = false

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
	replaceNegative(rpn)
	create1x(rpn)
	sortit(rpn)
	sortit2(rpn)
	simpleFactor(rpn)
	if needReSimplify then simplify(rpn) end

	return rpn
end

function infixSimplify(infix)
	
	return infix
end

function create1x(rpn, start)
	local token
	for i=(start or 1), #rpn do
		token	= rpn[i]
		if not tonumber(token) and not operator[token] then
			table.remove(rpn, i)
			table.insert(rpn, i, "*")
			table.insert(rpn, i, token)
			table.insert(rpn, i, "1")
			create1x(rpn, i+2)
			break
		end
	end
	
	return rpn
end

function delete1x(infix)
	infix = string.gsub(infix,"+1*x","+x")
	infix = string.gsub(infix,"-1*x","-x")
	return infix
end

function sortit2(rpn)
	mstable(rpn)
	local len	= #rpn
	local token
	local op
	
	local pos
	for i=1, len do
		a	= rpn[i]
		b	= rpn[i+1]
		o	= rpn[i+2]
		if not operator[a] and not operator[b] and operator[o] then
			pos	= i
			op	= o
			break
		end
	end
	

	if pos then
		local j	= 0
		for i=pos+3, len do 
			j	= j+1
			if not (op == rpn[i] and not operator[rpn[pos-j]]) then
				j	= j-1
				break
			end
		end
		
		if j == 0 then 
			return rpn
		end

		local done	= simpgroup(rpn, pos-j, pos + 3 + j, op)

		if done then
			--sortit2(rpn)
			return rpn
		end
	else
		return rpn
	end
end


-- Create a new RPN valid group from data values. startgroup ('a') is need to fix the previous RPN group
function creategroup(datatable, operator, startgroup)
	local group	=	{}
	
	group[1]	= startgroup or table.remove(datatable, 1)

	for _, value in ipairs(datatable) do
		table.insert(group, tostring(value))	-- tostring to be sure all data is in strings when we put it back in the RPN table
		table.insert(group, operator)
	end
	
	return group
end

-- Simplify the group. If startgroup is not nil, then it is part of a previous RPN group
function simpgroup(rpn, posa, posb, o, startgroup)
	local len	= #rpn
	local n	= posb-posa		-- The length of the RPN group we are handling
	local datatable	= {}
	
	-- We might need to find another solution.
	local oldrpn	= copyTable(rpn)
	
	
	-- We need to handle these stuff different. This is for later, as currently they can give faulty results
	-- We should change add negative sign's to numbers and create a special rational number type
	if o == "/"  or o =="-" or o =="^" then
		return
	end
	
	-- Remove the ENTIRE (and possible the last operator of the previous RPN group) and put the datavalues in a separate table
	local d
	for i=posa, posb do
		d	= table.remove(rpn, posa)
		
		if not operator[d] then 
			table.insert(datatable, d)
		end
	end
	
	-- Sort the table, so we can easily simplify it
	table.sort(datatable)	-- sort the datatable
	
	-- combine numbers together
	local n1, n2
	
	while tonumber(datatable[1]) and tonumber(datatable[2]) do
		datatable[1]	= operator[o][3](datatable[1], table.remove(datatable, 2))
	end
	
	-- create a RPN valid group of the remaining data values
	local group	= creategroup(datatable, o, startgroup)
	
	-- Reinsert the group into our RPN table
	for k, value in ipairs(group) do
		table.insert(rpn, posa+k-1, value)
	end

	return not compareTable(oldrpn, rpn)
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
		out	= i+1
		c	= rpn[i]
		o	= rpn[i+1]
		
		if o ~= ro or operator[c] then
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
	
	for i=1, len-2 do 
		if breakuntil>i then 
			break
		end
		
		local a	= rpn[i]
		local b	= rpn[i+1]
		local o	= rpn[i+2]
		if not operator[b] and operator[o] then
		
			-- Alright, we look for the start of a new group. 'a' CAN be an operator of a group before that.
			-- We use it determine the group type we detected. We may never lose 'a', as it is needed for correct RPN
			-- Example group if 'a' is an operator:
			-- * 9 + 6 +
			-- If 'a' is not an operator
			-- 8 9 + 6 +
			-- We can simplify both groups, but we need to take 'a' in account
			
			-- Find the group
			local posb	= findgroup(rpn, i, o)
			
			-- Simplify (if it can) the group.
			local done	= simpgroup(rpn, i, posb, o, operator[a] and a)
			-- If there are changes, try to simplify it again. This is currently recursive, should change to non-recursive.
			if done then
				sortit(rpn)
				break
			end
		end
	end
	
	return rpn
end

function simpleFactor(rpn)
	local i=1
	local oldrpn = copyTable(rpn)
	while i<#rpn do
		-- let's find in the RPN stack the place where there are two operators in a row.
		-- The one at the end will be the global op and the one before will be the inside one.
		if i>5 then -- minimum required to perform any factorization ([coeff1][insideOP1][var][globalOP][coeff2][insideOP2][var])
					-- which is in RPN : [coeff1][var][insideOP1][coeff2][var][insideOP2][globalOP]
			insideOP2 = rpn[i]
			insideOP1 = rpn[i-3]
			globalOP = rpn[i+1]
			coeff1 = rpn[i-5]
			coeff2 = rpn[i-2]
			var1 = rpn[i-4]
			var2 = rpn[i-4]
			
			--print("hello world factor ?",coeff1,insideOP1,var1,globalOP,coeff2,insideOP2,var2)

			if strType(insideOP2) == "operator" and strType(globalOP) == "operator" then
				if insideOP1 == insideOP2 then
					-- Get coefficients for the each inner part
					-- Check for good (expected) types.  TO IMPROVE ! 2*x == x*2. Please re-order everything before !!!
					if strType(coeff1) == "numeric" and strType(coeff2) == "numeric" then -- todo : support variable coeffs.
						-- Get the variables for each coeff. Then check if it's the same variables we're dealing with.
						if var1 == var2 then
							debugPrint("simpleFactorisation possible. Doing it.")
							-- Well, it's all good ! Let's factor all that.
							-- in infix : [(][coeff1][globalOP][Coeff2][)][insideOP][Variable1]
							-- in RPN : [coeff1][coeff2][globalOP][var][insideOP1]
							rpn[i-4] = coeff2
							rpn[i-3] = globalOP
							rpn[i-2] = var1
							rpn[i-1] = insideOP1
							table.remove(rpn,i)
							table.remove(rpn,i)
						end
					end
				end
			end
		end
		i=i+1
	end
	if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
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

function replaceNegative(t)
	for i=1,#t-1,1 do
		if strType(t[i]) == "numeric" and t[i+1] == "-" then
			t[i] = "-" .. t[i]
			t[i+1] = "+"
		end
	end
end

