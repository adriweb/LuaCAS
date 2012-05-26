-- Copyright (c) 2009 Rob Hoelz <rob@hoelzro.net>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
  
local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable
local schar = string.char

module 'ansicolors'

local colormt = {}

function colormt:__tostring()
    return self.value
end

function colormt:__concat(other)
    return tostring(self) .. tostring(other)
end

function colormt:__call(s)
    return self .. s .. _M.reset
end

colormt.__metatable = {}

local function makecolor(value)
    return setmetatable({ value = schar(27) .. '[' .. tostring(value) .. 'm' }, colormt)
end

local colors = {
    -- attributes
    reset = 0,
    clear = 0,
    bright = 1,
    dim = 2,
    underscore = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,

    -- foreground
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    -- background
    onblack = 40,
    onred = 41,
    ongreen = 42,
    onyellow = 43,
    onblue = 44,
    onmagenta = 45,
    oncyan = 46,
    onwhite = 47,
}

for c, v in pairs(colors) do
    _M[c] = makecolor(v)
end--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

dofile 'other.lua'
 
cmdResult = "No Command"
 
local commands = {
	["diff"] = function(argsTable) cmdResult = "diff called on " .. tblinfo(argsTable) end,
	["limit"] = function(argsTable) cmdResult = "limit called on " .. tblinfo(argsTable) end,
	["sum"] = function(argsTable) cmdResult = "sum called on " .. tblinfo(argsTable) end,
	["product"] = function(argsTable) cmdResult = "product called on " .. tblinfo(argsTable) end,
	["integral"] = function(argsTable) cmdResult = "integral called on " .. tblinfo(argsTable) end,
	["showAbout"] = function(argsTable) cmdResult = c_multiSpace .. getAbout() end,
	["showStatus"] = function(argsTable) cmdResult = getStatus() end,
	["help"] = function(argsTable) cmdResult = getHelp() end,
	["debugON"] = function(argsTable) showDebug = true cmdResult = "---Debug output enabled---" end,
	["debugOFF"] = function(argsTable) showDebug = false cmdResult = "---Debug output disabled---" end,
	["treeON"] = function(argsTable) showTree = true cmdResult = "---Tree output enabled---" end,
	["treeOFF"] = function(argsTable) showTree = false cmdResult = "---Tree output disabled---" end,
	["stepsON"] = function(argsTable) showSteps = true cmdResult = "---Steps output enabled---" end,
	["stepsOFF"] = function(argsTable) showSteps = false cmdResult = "---Steps output disabled---" end
}

function checkCommand(input)
	local cmd
	for k,v in pairs(commands) do
		cmd = string.match(input,k)
		if cmd then local _, tmp = string.find(input, cmd) ; doCommand(cmd,input:sub(2+tmp)) return true end
	end
end

function doCommand(cmd, input)
	commands[cmd](input:split())
	if cmdResult ~= "No Command" then endCommand(cmdResult) end
	checkCommand(input)
end

function endCommand(cmdResult)
	prettyDisplay(cmdResult)
	cmdResult = ""
end

function getHelp()
	local theString = "List of available commands (besides basic math input) : "
	for cmd,_ in pairs(commands) do
		theString = theString .. c_multiSpace .. tostring(cmd)
	end
	return theString
end
lesgroupes = {}
i = 1
while i ~= 0 do
	i = findNextPlus(rpn)
	cptgrp = 1
	compteur = 2
	while compteur ~= 0 do
		i = i-1
		lesgroupes[cptgrp] = rpn[i] .. " " .. lesgroupes[cptgrp]
		if operator[rpn[i]] then
			compteur = compteur+2
		else
			cptgrp = cptgrp + 1
		end
		compteur = compteur - 1
	end
end

function findNextPlus(rpn)
	for k,v in pairs(rpn) do
		if v == "+" then return k end
	end
	return 0 -- probleme....
end
--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

dofile 'other.lua'
dofile 'tools.lua'
dofile 'rpn.lua'
dofile 'simple.lua'
dofile 'rpn2infix.lua'
dofile 'commands.lua'
dofile 'polyClass.lua'


function main()
	while input ~= "exit" do
		io.write("luaCAS> ")
		io.flush()
		input=io.read()
		if input:len()>0 then

			if input ~= input:gsub("(Ans)",rawResult) then
				input = input:gsub("(Ans)",rawResult)
				chgFlag = 1
			end

			_, finalRes = pcall(loadstring("return " .. input) or function() end)
			-- finalRes will contain the result if possible.

			symbolify(input)
			if not checkCommand(input) then
				if type(finalRes) ~= "number" then
					debugPrint("   Direct Calculation (via lua math engine) not possible.")
					debugPrint("   RPN expr is : " .. tblinfo(toRPN(input)))

					local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
					if colorize(improvedRPN) ~= colorize(input) and chgFlag == 0 then prettyDisplay(improvedRPN) end

					local simprpn = tblinfo(simplify(toRPN(input)))
					globalRPN = simprpn
					debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
					debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))

					if calculateRPN(simprpn) == "var error" then
						debugPrint("   got variable error in calculateRPN!")
						finalRes = convertRPN2Infix(simprpn)
					else
						print("this should never appear ? (main:53). simprpn was = ", simprpn)
						finalRes = convertRPN2Infix(tblinfo(simplify(toRPN("0+"..input))))
					end
					debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))

					rawResult = finalRes
					if colorize(factResult) ~= colorize(finalRes) and (improvedRPN ~= finalRes or colorize(improvedRPN) == colorize(input)) then
						prettyDisplay(finalRes)
					elseif not showSteps then
						prettyDisplay(finalRes)
					else
						debugPrint('   "Steps" result already was the final result. Not re-printing')
					end

				else
					debugPrint("   Direct Calculation via lua math engine.")
					rawResult = finalRes
					prettyDisplay(finalRes)
				end
			end

			io.write("\n")

			io.flush()

			chgFlag = 0
			isSimplifying = 0
			return 0
		end
	return 1
	end
end

function launch()
	retOK, theErr = pcall(main)
	if theErr and retOK ~= 1 then
		if string.len(theErr)>5 then print("", colors.onred .. "Error ! " .. colors.reset .. " " .. theErr) print("") end
		launch()
	end
end

print(getAbout())

launch()
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


function findNextPlus(rpn)
	for k,v in ipairs(rpn) do
		if v == "+" or v == "+ " or v == " +"  or v == " + " then return k end
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
--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

poly = class()

function poly:init(name, input)

end

function poly:factor()

end

function poly:getDegree()

end

function poly:getHighestCoeff()

end

-- TODO :D--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
-- This part mainly by Jim Bauwens
-- Shunting-Yard Algorithm

operator	= {}
operator["^"]	= {4, 1, function (a, b) return a^b end}
operator["*"]	= {3,-1, function (a, b) return a*b end}
operator["/"]	= {3,-1, function (a, b) return a/b end}
operator["+"]	= {1,-1, function (a, b) return a+b end}
operator["-"]	= {1,-1, function (a, b) return a-b end}

func	= {}
func["sqrt"]	= math.sqrt
func["sin"]	= math.sin
func["cos"]	= math.cos
func["exp"]	= math.exp

argument_seperator	= ","

function splitExpr(expr)
	local oper	= {"%+", "%-", "%*", "%/", "%^", "%(", "%)", "%w+"}
	for _, o in ipairs(oper) do
		expr	= expr:gsub(o, " %1 ")
	end
	local out	= expr:gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", ""):split()
	return out
end

function toRPN(expr)
	
	local rpn_out	= {}
	local rpn_stack	= {}
	
	local expr	= splitExpr(expr)
	
	if #expr == 0 then
		error("Invalid expression!")
	end
	
	local pos	= 0
	local token	= ""
	while pos<#expr do
		pos	= pos + 1
		token	= expr[pos]
		
		-- If the token is a number, then add it to the output
		if tonumber(token) then
			table.insert(rpn_out, token)
			
		-- If the token is a function, then push it to the stack
		elseif func[token] then
			-- We need a matching left parenthesis
			if expr[pos+1] ~= "(" then
				error("Attempt to use function as variable!")
			else
				table.insert(rpn_stack, token)
			end
			
		-- If the token is a function argument separator
		elseif token == argument_seperator then
			while true do
				local stack_token	= table.remove(rpn_stack)
				if stack_token == "(" then
					table.insert(rpn_stack, "(")
					break
				else
					table.insert(rpn_out, stack_token)
					if #rpn_stack == 0 then error("Expected ( before argument separator!") end
				end
			end
			
		elseif operator[token] then
			local o1	= operator[token]
			while true do
				local stack_token	= rpn_stack[#rpn_stack]
				if not stack_token then break end
				local o2	= operator[stack_token] 
				if o2 and ( (o1[2] == -1 and o1[1] <= o2[1]) or (o1[2] == 1 and o1[1] < o2[1]) ) then
					table.insert(rpn_out, table.remove(rpn_stack))
				else
					break
				end
			end
			table.insert(rpn_stack, token)
			
		-- If the token is a left parenthesis, then push it onto the stack.
		elseif token	== "(" then
			table.insert(rpn_stack, "(")
		
		elseif token	== ")" then
		
			local stack_token	= ""
			
			while true do
				stack_token	= table.remove(rpn_stack)
				if stack_token == "(" then
					break
				else
					table.insert(rpn_out, stack_token)
					if #rpn_stack == 0 then error("Mismatched parentheses!") end
				end
			end		
		
			if #rpn_stack>0 and func[rpn_stack[#rpn_stack]] then
				table.insert(rpn_out, table.remove(rpn_stack))
			end
			
		-- must be a variable
		else
			table.insert(rpn_out, token)
		end
	end
	
	for i=#rpn_stack, 1, -1 do
		token	= rpn_stack[i]
		if token == "(" or token == ")" then
			error("Mismatched parentheses!")
		else
			table.insert(rpn_out, token)
		end
	end
	
	return rpn_out
end


function calculateRPN(s)
  tmpVarRPNCalctb = {}
  tmpVarRPNCalcz = 0
  for tmpVarRPNCalctk in string.gfind(s,'%S+') do
    if string.find(tmpVarRPNCalctk,'^[-+*/]$')  then
      if 2>table.getn(tmpVarRPNCalctb) then tmpVarRPNCalcz = nil break end
      tmpVarRPNCalcy,tmpVarRPNCalcx = table.remove(tmpVarRPNCalctb),table.remove(tmpVarRPNCalctb)
      loadstring('tmpVarRPNCalcz=tmpVarRPNCalcx'..tmpVarRPNCalctk..'tmpVarRPNCalcy')()
    else
      tmpVarRPNCalcz = tonumber(tmpVarRPNCalctk)  if tmpVarRPNCalcz==nil then break end
    end
    table.insert(tmpVarRPNCalctb,tmpVarRPNCalcz)
  end
  tmpVarRPNCalcn = table.getn(tmpVarRPNCalctb)
  if tmpVarRPNCalcn==1 and tmpVarRPNCalcz then return(tmpVarRPNCalcz)
  elseif tmpVarRPNCalcn>1 or tmpVarRPNCalcz==nil then return('var error') end
end

--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
-- Lua Port and additions/fixes by Adriweb from : 
-- http://blog.boyet.com/blog/blog/postfix-to-infix-part-2-adding-the-parentheses/
 
function makeNumberNode(number)
    local node = {
        kind  = "number",
        value = number
    }
    return node
end

function makeVariableNode(var)
	local node = {
        kind  = "variable",
        value = var
    }
    return node
end
    
function makeOpNode(op, left, right)
    local precedence = 1
    if (op == "*") or (op == "/") then
        precedence = 2
    end
    local node = {
        kind       = "operator",
        operator   = op,
        precedence = precedence,
        left       = left,
        right      = right
    }
    return node
end
    
function convertRPN2Tree(rpnExpr)
    local stack = {}
    local i=0, ch, rhs, lhs
    
    while i<string.len(rpnExpr) do
    	i=i+1
    	local j = i
    	ch = ""
    	while " "~=(string.sub(rpnExpr,j,j)) and j <= string.len(rpnExpr) do
        	ch = ch .. string.sub(rpnExpr,j,j)
        	j=j+1
        end
        if ch~=" " and ch ~= "" then
			if isNumeric(ch) then
				stackPush(stack,makeNumberNode(ch))
			elseif string.find("*-+/^",ch) then
				rhs = stackPop(stack)
				lhs = stackPop(stack)
				stackPush(stack,makeOpNode(ch, lhs, rhs))
			else
				stackPush(stack,makeVariableNode(ch))
			end
			if i+string.len(ch) > string.len(rpnExpr) then
        		i=i+1
    		else
    			i=i+string.len(ch)
    		end
        end
    end        
        
    return stackPop(stack)
end
    
function needParensOnLeft(node)
    return (node.left.kind == "operator") and (node.left.precedence < node.precedence)
end
    
function needParensOnRight(node)
    if (node.right.kind == "number" or node.right.kind == "variable") then
        return false
    end
    if (node.operator == "+" or node.operator == "*") then
        return node.right.precedence < node.precedence
    end
    return node.right.precedence <= node.precedence
end
    
function visit(node)
    if node.kind=="number" or node.kind=="variable" then
        return node.value
    end
        
    local lhs = visit(node.left)
    if needParensOnLeft(node) then
        lhs = '(' .. lhs .. ')'
    end
        
    local rhs = visit(node.right)
    if needParensOnRight(node) then
        rhs = '(' .. rhs .. ')'
    end
        
    return lhs .. node.operator .. rhs
end
  
function convertRPN2Infix(rpnExpr) -- input and output are strings
	if strType(rpnExpr) == "numeric" then return rpnExpr end
    local tree = convertRPN2Tree(rpnExpr)
    if showTree and showDebug then treeDump("tree",tree) end
    local infixExpr = tree and visit(tree) or "error"
    return infixExpr
end
--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
-- Parts also by Jim Bauwens

dofile "other.lua"
 
needReSimplify = false
possibleCommut = {}
doneCommut = {}
alreadyCommut = {}
commutList = {}
possibleCommut = {}
alreadyPassed = 0
rpnSave = {}


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

function simplify2(rpn)

		replaceNegative(rpn)
		sortit(rpn)
		sortit2(rpn)
		create1x(rpn)
		replaceP(rpn)
		rpn = simpleFactor(rpn)
		deleteUseless(rpn)
	
	if needReSimplify or isSimplifying==1 then commutlist = detectCommutGroup(rpn) isSimplifying = 1 end
	if needReSimplify then 
		rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
		simplify2(rpn) 
	end
	rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
	if alreadyPassed == 0 then alreadyPassed = 1 needReSimplify = false simplify2(rpn) end
	return rpn
end

function simplify(rpn)

	    isSimplifying = 0
		needReSimplify = false
		rpn = simplify2(rpn)
		needReSimplify = true
					
		local perfectRpn = copyTable(rpn)

		while needReSimplify do
			debugPrint("	Entering simplify's commut find loop")
			if findNextPlus(rpn) == 0 then 
				perfectRpn = {}
				perfectRpn = copyTable(simpleFactor(rpn))
				break
			end
			rpn = table.concat(rpn," "):gsub("   ","  "):gsub("  "," "):split(" ")
			local commutList2 = detectCommutGroup(rpn)
			listRpn = createPossibleRpnTable(rpn,commutList2)
				for _,v in pairs(listRpn) do
					v = create1x(v)
					newV = simplify2(v)
					newV = simplify2(newV)
					v = create1x(v)
					newV = create1x(newV)
					if (numberOfMult(newV)<numberOfMult(v)) then 
						perfectRpn = {}
						perfectRpn = copyTable(newV)
						perfectRpn = deleteUseless(perfectRpn)
						needReSimplify = true
						break
					else needReSimplify = false
					end
				end
			rpn = {}
			rpn = copyTable(perfectRpn)
		end	
		perfectRpn = sortit(perfectRpn)
		perfectRpn = sortit2(perfectRpn)
		return perfectRpn
end

function infixSimplify(infix)
	-- useless ?
	return infix
end

function create1x(rpn, start)
	local oldrpn = copyTable(rpn)
	local token
	for i=(start or 1), #rpn do
		token = rpn[i]
		if strType(token) == "variable" then
			if (not((strType(rpn[i+1]) == "numeric" or strType(rpn[i+1]) == "variable") and (rpn[i+2] == "*" or rpn[i+2] == "/"))) and ((i+1 > #rpn) or (rpn[i+1]~="*" and rpn[i+1]~="/")) then
				table.remove(rpn, i)
				table.insert(rpn, i, "1")
				table.insert(rpn, i+1, token)
				table.insert(rpn, i+2, "*")
			end
			create1x(rpn, i+2)
			break
		end
	end
	if isSimplifying == 1 and convertRPN2Infix(tblinfo(rpn)) ~= input then stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn))) end
	isSimplifying = isSimplifying + 1
	if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
	return rpn
end

function deleteUseless(rpn, start)
	local oldrpn = copyTable(rpn)
	local token
	
	for i=(start or 2), #rpn do
		token = rpn[i]
		if strType(token) == "variable" or strType(token) == "numeric" then
			if rpn[i-1] == "1" and rpn[i+1] == "*" then
				table.remove(rpn, i+1)
				table.remove(rpn, i-1)
			end
			deleteUseless(rpn, i+1)
			break
		end
		if strType(token) == "operator" then
			if token == "/" and rpn[i-1] == "1" then
				table.remove(rpn, i)
				table.remove(rpn, i-1)
			end
			deleteUseless(rpn, i+1)
			break
		end
	end
	return rpn
end

function replaceP(rpn)
	local len	= #rpn
	local a,b,o1,o2
	for i=1, len-4 do
		a	= rpn[i]
		b	= rpn[i+1]
		o1	= rpn[i+2]
		o2	= rpn[i+3]
		
		if not operator[a] and not operator[b] and operator[o1] and operator[o2] and o1 == o2 then
			rpn[i+1]	= o1
			rpn[i+2]	= b
		end
	end
	
	return rpn
end

function sortit2(rpn, offs)
	mstable(rpn)
	local len	= #rpn
	local token
	local op
	
	local pos
	for i=(offs or 1), len do
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
		
		local done, off = simpgroup(rpn, pos-j, pos + 2 + j, op)
		sortit2(rpn, off)
		return rpn
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
	local oldrpn = copyTable(rpn)
	
	-- We need to handle these stuff different. This is for later, as currently they can give faulty results
	-- We should change add negative sign's to numbers and create a special rational number type
	if o == "/"  or o =="-" or o =="^" then
		return false, posb+1 -- needs fixing :D #TODO
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

	return not compareTable(oldrpn, rpn), posa+#group-1
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
			local done = simpgroup(rpn, i, posb, o, operator[a] and a)
			-- If there are changes, try to simplify it again. This is currently recursive, should change to non-recursive.
			if done then
				sortit(rpn)
				break
			end
		end
	end
	
	return rpn
end

function simpleFactor(rpn, start)

	local i=start or 1
	local oldrpn = copyTable(rpn)
	
	-- TODO  :   algo simplification pour fractions avec haut == bas  ( -> 1)
	while i<#rpn-5 do -- minimum required to perform any factorization ([coeff1][insideOP1][var][globalOP][coeff2][insideOP2][var])
					  -- which is in RPN : [coeff1][var][insideOP1][coeff2][var][insideOP2][globalOP]
		-- let's find in the RPN stack the place where there are two operators in a row.
		-- The one at the end will be the global op and the one before will be the inside one.
			insideOP2 = rpn[i+5]
			insideOP1 = rpn[i+2]
			globalOP = rpn[i+6]
			coeff1 = rpn[i]
			coeff2 = rpn[i+3]
			var1 = rpn[i+1]
			var2 = rpn[i+4]
			if strType(insideOP2) == "operator" and strType(globalOP) == "operator" then
				if (insideOP1 == insideOP2) and insideOP1 ~= "^" and globalOP ~= "/" and globalOP ~= "^" then
					-- Get coefficients for the each inner part
					-- Check for good (expected) types.
					if strType(coeff1) and strType(coeff2) then
						-- Get the variables for each coeff. Then check if it's the same variables we're dealing with.
						if var1 == var2 then
							debugPrint("   simpleFactorisation possible. Doing it.")
							debugPrint("   Possible to factor : " .. coeff1 .. " " .. insideOP1.. " " .. var1.. " " .. globalOP.. " " .. coeff2.. " " .. insideOP2.. " " .. var2)
							debugPrint("   Which is in RPN : " .. tblinfo(rpn))
							-- Well, it's all good ! Let's factor all that.
							-- in infix : [(][coeff1][globalOP][Coeff2][)][insideOP][Variable1]
							-- in RPN : [coeff1][coeff2][globalOP][var][insideOP1]
							rpn[i+1] = coeff2
							rpn[i+2] = globalOP
							rpn[i+3] = var1
							rpn[i+4] = insideOP1
							table.remove(rpn,i+5)
							table.remove(rpn,i+5)
							factResult = convertRPN2Infix(tblinfo(rpn))
							stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn)))
							rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
						end
					end
				end
			end
		i=i+1
		
	end
	
	--if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
	if (#oldrpn > #rpn) then needReSimplify = true else needReSimplify = false end
	
	return rpn
end

function detectCommutGroup(rpn)
			
			debugPrint("Entering the new group detection")
			------- test
			--print("   TEST START")
			
			--print(type(rpn), tblinfo(rpn))		
			--rpn = rpn:split(" ")
			rpngroupe = {}
			lesgroupes = {}
			possibleCommut = {}
			commutList = {}
			nbrDeGroupes = 2
			cptgrp = 1
			i = 1
			while i > 0 do
				debugPrint("Inside boucle while commut : " .. i)
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
				--print(tblinfo(rpn))
				for tmp=1,findNextPlus(rpn) do
					table.remove(rpn,1)
				end
				--print(tblinfo(rpn))
				
			
				lesgroupes = resort(lesgroupes)				
				lesgroupes[nbrDeGroupes-1],lesgroupes[nbrDeGroupes] = lesgroupes[nbrDeGroupes],lesgroupes[nbrDeGroupes-1]
				if lesgroupes[nbrDeGroupes] or lesgroupes[nbrDeGroupes-1] then
					gr = (lesgroupes[nbrDeGroupes-1] or "") .. (lesgroupes[nbrDeGroupes] or "") .. "+ "
					table.insert(rpn,1,gr)
				end
				
				i = findNextPlus(rpn) -- RHAAAAA
					
				nbrDeGroupes = nbrDeGroupes + 2
			end
			
			debugPrint("Fin while commut")
			local rpnCopy = {}
			for k,v in pairs(rpn) do
				local newV = v:gsub("  ", " ")
				table.insert(rpnCopy, newV:split())
			end
			if #rpnCopy > 1 then
				rpnCopy = copyTable(rpnCopy[2])
			else
				rpntemp = copyTable(rpnCopy[1])
				rpnCopy = nil
				rpnCopy = copyTable(rpntemp)
			end
			local tmpRPN = {}
			for indice=1,#rpnCopy do
				if rpnCopy[indice] or rpnCopy[indice]~="" or rpnCopy[indice]~=" " then
					table.insert(tmpRPN,rpnCopy[indice])
				end
			end
			rpnCopy = nil
			rpnCopy = copyTable(tmpRPN)
			
			for k,v in pairs(rpnCopy) do
				if not v then table.remove(rpnCopy[k]) end
			end
			
			table.remove(rpnCopy,#rpnCopy)
				
			rpn = nil
			rpn = copyTable(rpnCopy)
			
			possibleCommut = lookForSimilarVariable(lesgroupes)
			commutList = generateEachCommmut(possibleCommut,rpn)
	return commutList

end


function getNewRPN(rpn)
	needReSimplify = true
	return detectCommutGroup(rpn)
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
	return "variable" -- meh
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

function symbolify(infix)
	-- string.gsub(infix,"π","pi")  -- do stuff like that but check it's a variable name alone. Not part of a bigger var name.
	return infix
end

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

function numberOfMult(theRpn)
	local compt = 0
	for _,v in pairs(theRpn) do
		if v and v == "*" then compt = compt + 1 end
	end
	return compt
end
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


--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------
-- some parts are from everywhere :D
 
colors = require 'ansicolors'

function debugPrint(...)
	if showDebug then print(...) end
end

class = function(prototype)
local derived={}

 	if prototype then
		derived.__proto	= prototype
 		function derived.__index(t,key)
 			return rawget(derived,key) or prototype[key]
 		end
 	else
 		function derived.__index(t,key)
 			return rawget(derived,key)
 		end
 	end
 	
 	function derived.__call(proto,...)
 		local instance={}
 		setmetatable(instance,proto)
 		instance.__obj	= true
 		local init=instance.init
 		if init then
 			init(instance,...)
 		end
 		return instance
 	end
 	
 	setmetatable(derived,derived)
 	return derived
end


function string.uchar(c)
	c = c<256 and c or 100
	return string.char(c)
end

function string:ubyte(...)
	return string.byte(self, ...)
end

function string:usub(...)
	return string.sub(self, ...)
end

function string:split(pattern)
	self_type = type(self)
	pattern_type = type(pattern)
	if (self_type ~= 'string' and self_type ~= 'number') then
		buffer = [[bad argument #1 to 'split' (string expected, got ]] .. self_type .. [[)]]
		error(buffer)
	end
	if (pattern_type ~= 'string' and pattern_type ~= 'number' and pattern_type ~= 'nil') then
		buffer = [[bad argument #2 to 'split' (string expected, got ]] .. pattern_type .. [[)]]
		error(buffer)
	end
	
	pattern = pattern or '%s+'
	local start = 1
	local list = {}
	while true do
		local b, e = string.find(self, pattern, start)
		if b == nil then	
			list[#list+1] = string.sub(self, start)
			break
		end
		list[#list+1] = string.sub(self, start, b-1)
		start = e + 1
	end
	return list
end

function string:split2(pat)
  pat = pat or '%s+'
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end

function tblinfo(tbl)
	local out = ""
	for k, v in pairs(tbl) do
		out	= out .. v .. " "
		--print(k, v)
	end
	return out
end

function tblinfo2(tbl)
	local out = ""
	for k, v in pairs(tbl) do
		out	= out .. v .. [[ 
 ]]
		--print(k, v)
	end
	return out
end

function strReplace(str,pattern,remplacement)
	local new,index
	str = tostring(str)
	new,index = string.gsub(str,pattern,remplacement)
	return new
end

function isNumeric(str)
	return tonumber(str) ~= nil
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function stackPush(stack,...)
	table.insert(stack,...)
end

function stackPop(stack)
	local lastval = stack[#stack]
	table.remove(stack,#stack)
	return lastval
end

add = ""
DDDONE = {}
function dump(name, reference)
	if type(reference) == "userdata" then
		reference = getmetatable(reference)
	end
	
	if type(reference) == "table" and not DDDONE[reference] and name ~= "DDDONE" then
		DDDONE[reference] = true
		print(add ..  tostring(name))
		add = add .. "\t"
		table.foreach(reference, dump)
		add = add:sub(1,#add-1)
	elseif type(reference) == "function" then
		print(add .. name)
	else
		print(add .. name, "-", reference)
	end
end

function treeDump(name, reference)
	if type(reference) == "userdata" then
		reference = getmetatable(reference)
	end
	
	if type(reference) == "table" and not DDDONE[reference] and name ~= "DDDONE" then
		DDDONE[reference] = true
		print(tostring(name))
		add = add .. "\t"
		table.foreach(reference, dump)
		add = add:sub(1,#add-1)
	elseif type(reference) == "function" then
		print(name)
	else
		print(reference)
	end
end

function colorize(str)
	str = tostring(str)
    str = str:gsub("%(",colors.yellow .. "%(" .. colors.reset)
   	str = str:gsub("%)",colors.yellow .. "%)" .. colors.reset)
   	str = str:gsub("%+",colors.cyan .. "%+" .. colors.reset)
   	str = str:gsub("-",colors.cyan .. "-" .. colors.reset)
   	str = str:gsub("%*",colors.cyan .. "%*" .. colors.reset)
   	str = str:gsub("%/",colors.cyan .. "%/" .. colors.reset)
   	str = str:gsub("%^",colors.cyan .. "%^" .. colors.reset)
   	str = str:gsub("false",colors.red .. "false" .. colors.reset)
   	str = str:gsub("true",colors.green .. "true" .. colors.reset)
   	-- do for variables (but that will change the way we analyze :  check for previous and next char to see if also char (then its a function, or, if not (check if func) then it's a multi-char variable ..)
   	
	return str
end


function mstable(tbl)
	for k,v in ipairs(tbl) do
		tbl[k]	= tostring(v)
	end
	return tbl
end

function compareTable(tbl1, tbl2) 
	local len	= #tbl1
	if len ~= #tbl2 then return false end
	
	for i=1, len do
		if tbl1[i] ~= tbl2[i] then return false end
	end
	
	return true
end

function copyTable(tbl)
	local out	= {}
	for k,v in pairs(tbl) do
		out[k]	= v
	end
	return out
end

function prettyDisplay(str)
	print("     =  " .. colorize(str))
end

function stepsPrettyDisplay(str)
	if showSteps or showDebug then prettyDisplay(str) end
end
