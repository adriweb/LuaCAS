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
		
		symbolify(input)
		checkCommand(input)
				
		debugPrint("   RPN expr is : " .. tblinfo(toRPN(input)))
		
		local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
		if colorize(improvedRPN) ~= colorize(input) then prettyDisplay(improvedRPN) end
			
		local simprpn = tblinfo(simplify(toRPN(input)))
		
		debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
		debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))
		
		if calculateRPN(simprpn) == "var error" then
			debugPrint("got variable error in calculateRPN!")
			finalRes = convertRPN2Infix(simprpn)
		else
			finalRes = convertRPN2Infix(tblinfo(simplify(toRPN("0+"..input))))
		end
		debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))
		
		if improvedRPN ~= finalRes then prettyDisplay(finalRes) end
				
		io.write("\n")
		io.flush()
		
	end
end

