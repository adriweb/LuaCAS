--------------------------------------
----           LuaCAS             ----
----            v0.1              ----
----                              ----
----  Adrien 'Adriweb' Bertrand   ----
----            2012              ----
----                              ----
----         GPL License          ----
--------------------------------------

dofile 'tools.lua'
dofile 'rpn.lua'
dofile 'simple.lua'
dofile 'rpn2infix.lua'
dofile 'commands.lua'

showDebug = false

while true do
	io.write("luaCAS> ")
	io.flush()
	local input=io.read()
   	if input:len()>0 then
		
		checkCommand(input)
				
		debugPrint("   RPN expr is : " .. tblinfo(toRPN(input)))
		
		local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
		if colorize(improvedRPN) ~= input then	prettyDisplay(improvedRPN)	end
			
		local simprpn = tblinfo(simplify(toRPN(input)))
		
		debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
		debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))
		
		local finalRes = convertRPN2Infix(simprpn)
		debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))
	
		prettyDisplay(finalRes)
				
		io.write("\n")
		io.flush()
		
	end
end

