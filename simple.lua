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

function reorder(expr)
	local theTable = {}
	local cstTable = {}
	local varTable = {}
	local opTable = {}
	local i
	    
    while i<string.len(rpnExpr) do
    	i=i+1
    	local j = i
    	local ch = ""
    	local type1 = strType
    	local type2
    	
    	while " "~=(string.sub(rpnExpr,j,j)) and j <= string.len(rpnExpr) do
        	ch = ch .. string.sub(rpnExpr,j,j);
        	j=j+1
        end
        
        -- refaire cette boucle  ^  en traitant les groups selon les parentheses
        
        
        if ch~=" " and ch ~= "" then

			-- regarder les types ( strType() ) et push dans le bon stack

			if i+string.len(ch) > string.len(rpnExpr) then
        		i=i+1
    		else
    			i=i+string.len(ch)
    		end
        end
    end        
        
    stackPop(stack)
	
	return expr
end

function strType(str)
	if isNumeric(str) then return "numeric" end
	if string.find("*-+/^",str) then return "operator" end
	if string.find(" ",str) then return "blank" end
	-- if string.find("sin",str) then return "function" end    --> do all other cases
end







