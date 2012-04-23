--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

local colors = require 'ansicolors'

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

function colorize(str)
	str = tostring(str)
    str = str:gsub("%(",colors.yellow .. "%(" .. colors.reset)
   	str = str:gsub("%)",colors.yellow .. "%)" .. colors.reset)
   	str = str:gsub("%+",colors.cyan .. "%+" .. colors.reset)
   	str = str:gsub("-",colors.cyan .. "-" .. colors.reset)
   	str = str:gsub("%*",colors.cyan .. "%*" .. colors.reset)
   	str = str:gsub("%/",colors.cyan .. "%/" .. colors.reset)
   	str = str:gsub("%^",colors.cyan .. "%^" .. colors.reset)
   	-- do for variables (but that will change the way we analyze :  check for previous and next char to see if also char (then its a function, or, if not (check if func) then it's a multi-char variable ..)
   	
	return str
end


function mstable(tbl)
	for k,v in ipairs(tbl) do
		tbl[k]	= tostring(v)
	end
	return tbl
end
