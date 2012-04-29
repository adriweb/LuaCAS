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
dofile 'polyClass.lua'

showDebug = false
showSteps = false

input = ""

function main()
while input ~= "exit" do
	io.write("luaCAS> ")
	io.flush()
	input=io.read()
   	if input:len()>0 then
		
		symbolify(input)
		if not checkCommand(input) then
				
			debugPrint("   RPN expr is : " .. tblinfo(toRPN(input)))
			
			local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
			if colorize(improvedRPN) ~= colorize(input) then prettyDisplay(improvedRPN) end
				
			local simprpn = tblinfo(simplify(toRPN(input)))
			
			debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
			debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))
			
			if calculateRPN(simprpn) == "var error" then
				debugPrint("   got variable error in calculateRPN!")
				finalRes = convertRPN2Infix(simprpn,true) -- true is for isFinal
			else
				finalRes = convertRPN2Infix(tblinfo(simplify(toRPN("0+"..input))),true) -- true is for isFinal
			end
			debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))
			
			if improvedRPN ~= finalRes or colorize(improvedRPN) == colorize(input) then prettyDisplay(finalRes) end

		end
				
		io.write("\n")
		io.flush()
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

launch()
