function isClean(n)
	return math.floor(n) == n
end

function div(a,b)
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

function simplify(rpn)
	local pos	= 0
	local n1, n2, op
	
	while true do 
		pos	= pos + 1
		n1	= tonumber(rpn[pos-2])
		n2	= tonumber(rpn[pos-1])
		op	= rpn[pos]
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
