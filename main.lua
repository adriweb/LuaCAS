dofile 'tools.lua'
dofile 'rpn.lua'
dofile 'simple.lua'

repeat
	io.write("luaCAS> ")
	io.flush()
	input=io.read()
   	if input:len()>0 then
   		resultStr = tblinfo(toRPN(input))
		resultStr = tblinfo(simplify(toRPN(input)))
		io.write("\n")
		io.flush()
	end
until input=="quit" or input=="exit"

local s = resultStr
  tb = {}  z = 0
  for tk in string.gfind(s,'%S+') do
    if string.find(tk,'^[-+*/]$')  then
      if 2>table.getn(tb) then z = nil break end
      y,x = table.remove(tb),table.remove(tb)
      loadstring('z=x'..tk..'y')()
    else
      z = tonumber(tk)  if z==nil then break end
    end
    table.insert(tb,z)
  end
  n = table.getn(tb)
  if n==1 and z then print(z)
  elseif n>1 or z==nil then print('error') end
