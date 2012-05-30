-------------------------------------
----            LuaCAS           ----
----             v0.4            ----
----                             ----
----  Adrien 'Adriweb' Bertrand  ----
----             2012            ----
----                             ----
----         GPL License         ----
-------------------------------------
-- some parts are from everywhere :D

colors = require'ansicolors'

showColors = true
outputStack = {}

function debugPrint(...)
    if showDebug then print(...) end
end

class = function(prototype)
    local derived = {}

    if prototype then
        derived.__proto = prototype
        function derived.__index(t, key)
            return rawget(derived, key) or prototype[key]
        end
    else
        function derived.__index(t, key)
            return rawget(derived, key)
        end
    end

    function derived.__call(proto, ...)
        local instance = {}
        setmetatable(instance, proto)
        instance.__obj = true
        local init = instance.init
        if init then
            init(instance, ...)
        end
        return instance
    end

    setmetatable(derived, derived)
    return derived
end


function string.uchar(c)
    c = c < 256 and c or 100
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
            list[#list + 1] = string.sub(self, start)
            break
        end
        list[#list + 1] = string.sub(self, start, b - 1)
        start = e + 1
    end
    return list
end

function justWords(str) local t = {} for w in str:gmatch("%S+") do table.insert(t, w) end return t end

function string:justwords() local t = {} for w in self:gmatch("%S+") do table.insert(t, w) end return t end

function string:split2(pat)
    pat = pat or '%s+'
    local st, g = 1, self:gmatch("()(" .. pat .. ")")
    local function getter(segs, seps, sep, cap1, ...)
        st = sep and seps + #sep
        return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
    end

    return function() if st then return getter(st, g()) end end
end

function tblinfo(tbl)
    local out = ""
    for k, v in pairs(tbl) do
        out = out .. v .. " "
        --print(k, v)
    end
    return out
end

function tblinfo2(tbl)
    local out = [[

 ]]
    for k, v in pairs(tbl) do
        out = out .. v .. [[

 ]]
    end
    return out
end

function strReplace(str, pattern, remplacement)
    local new, index
    str = tostring(str)
    new, index = string.gsub(str, pattern, remplacement)
    return new
end

function isNumeric(str)
    return tonumber(str) ~= nil
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.ends(String, End)
    return End == '' or string.sub(String, -string.len(End)) == End
end

function stackPush(stack, ...)
    table.insert(stack, ...)
end

function stackPop(stack)
    local lastval = stack[#stack]
    table.remove(stack, #stack)
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
        print(add .. tostring(name))
        add = add .. "\t"
        table.foreach(reference, dump)
        add = add:sub(1, #add - 1)
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
        add = add:sub(1, #add - 1)
    elseif type(reference) == "function" then
        print(name)
    else
        print(reference)
    end
end

function colorize(str)
    str = tostring(str)

    if showColors then
        str = str:gsub("%(", colors.yellow .. "%(" .. colors.reset)
        str = str:gsub("%)", colors.yellow .. "%)" .. colors.reset)
        str = str:gsub("%+", colors.cyan .. "%+" .. colors.reset)
        str = str:gsub("-", colors.cyan .. "-" .. colors.reset)
        str = str:gsub("%*", colors.cyan .. "%*" .. colors.reset)
        str = str:gsub("%/", colors.cyan .. "%/" .. colors.reset)
        str = str:gsub("%^", colors.cyan .. "%^" .. colors.reset)
        str = str:gsub("false", colors.red .. "false" .. colors.reset)
        str = str:gsub("true", colors.green .. "true" .. colors.reset)
        -- do for variables (but that will change the way we analyze :  check for previous and next char to see if also char (then its a function, or, if not (check if func) then it's a multi-char variable ..)
    end

    return str
end


function mstable(tbl)
    for k, v in ipairs(tbl) do
        tbl[k] = tostring(v)
    end
    return tbl
end

function compareTable(tbl1, tbl2)
    local len = #tbl1
    if len ~= #tbl2 then return false end

    for i = 1, len do
        if tbl1[i] ~= tbl2[i] then return false end
    end

    return true
end

function copyTable(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = v
    end
    return out
end

function prettyDisplay(str)
	if showDebug then
		print("     =  " .. colorize(str))
	else
		table.insert(outputStack,str)
	end
end

function unpackOutputStack()
	if showSteps or showDebug then
		for _,str in pairs(outputStack) do
			if str and str~="nil" then print("     =  " .. colorize(str)) end
		end
	else
		print("     =  " .. colorize(outputStack[#outputStack]))
	end
end

function cleanOutputStack()
	-- TODEBUG / TODO ? : avoid removing good stuff like "x" when showSteps and input == "x" ( now -> "1*x" )
	outputStack = removeTableDuplicates(outputStack)
	--print("avant", tblinfo2(outputStack))
	if showSteps or showDebug then
		if #outputStack > 2 then table.remove(outputStack,1) end
		--print("milieu", tblinfo2(outputStack))
		local indexMult, lengthMult = getMultiplications(outputStack)
		local indexShort, lengthShort = getShortestValue(outputStack)
		local indexLoop = indexShort > indexMult and indexShort or indexMult
		for i=#outputStack, indexLoop, -1 do
			if i ~= indexLoop then
				if outputStack[indexLoop+1] then
					if outputStack[i]:len() > outputStack[indexLoop+1]:len() then table.remove(outputStack,i) end
				else 
					table.remove(outputStack,i)
				end
			end
		end
	end
	--print("apres", tblinfo2(outputStack))
end

function getShortestValue(tt)
	local shortestIndex = -1
	local valueLength = -1
	for i,v in ipairs(tt) do
		v = tostring(v)
		if v:len() < valueLength or valueLength < 0 then
			valueLength = v:len()
			shortestIndex = i
		end
	end
	return shortestIndex, valueLength
end

function getMultiplications(tt)
	local index = -1
	local numbers = -1
	for i,v in ipairs(tt) do
		if Count_Substring(v,"*") <= numbers or numbers < 0 then
			numbers = Count_Substring(v,"*")
			index = i
		end
	end
	return index, numbers
end

function Count_Substring( s1, s2 )
 s1,s2 = tostring(s1), tostring(s2)
 local magic =  "[%^%$%(%)%%%.%[%]%*%+%-%?]"
 local percent = function(s)return "%"..s end
    return select( 2, s1:gsub( s2:gsub(magic,percent), "" ) )
end

-- Count the number of times a value occurs in a table
function table_count(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

-- Remove duplicates from a table array (doesn't currently work on key-value tables)
function removeTableDuplicates(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(table_count(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

function removeTableDuplicates2(tbl) -- Jim's sorcery (which is awesome btw)
	local t={}
	for k,v in ipairs(tbl) do
		t[v] = true
	end
	local new={}
	for k,v in pairs(t) do
		table.insert(new, k)
	end
	return new
end

function stepsPrettyDisplay(str)
    if showSteps or showDebug then prettyDisplay(str) end
end
