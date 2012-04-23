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

debug = true

while true do
	io.write("luaCAS> ")
	io.flush()
	local input=io.read()
   	if input:len()>0 then
   	
   	checkCommand(input)
   		   	
   	if debug then 
   		
   		print("   RPN expr is : " .. tblinfo(toRPN(input)))
   		
   		local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
   		local coloredImprovedRPN = colorize(improvedRPN)
   		print("   Colored improved input : " .. coloredImprovedRPN)
   	
   	end
   		
   	local simprpn = tblinfo(simplify(toRPN(input)))
   	
   	if debug then
		print("   RPN expr of simplified is : " .. colorize(simprpn))
		print("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))
		print("   Simplified infix from RPN is : " .. colorize(convertRPN2Infix(simprpn)))
	end
				
	finalRes = tblinfo(simplify(toRPN(convertRPN2Infix(simprpn))))
	if debug then print("   Re-simplified RPN : " .. colorize(finalRes)) end
	print("   Infix from that ^ : " .. colorize(convertRPN2Infix(finalRes)))
			
	io.write("\n")
	io.flush()
		
	end
	
end

function displayResult()
	print(colorize(finalRes))
end
