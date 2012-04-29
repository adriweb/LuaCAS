--------------------------------------
----           LuaCAS             ----
----            v0.2              ----
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
showTree = false
showSteps = false

input = ""
rawResult = "NoResult"
chgFlag = 0

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
					
					debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
					debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))
					
					if calculateRPN(simprpn) == "var error" then
						debugPrint("   got variable error in calculateRPN!")
						finalRes = convertRPN2Infix(simprpn)
					else
						finalRes = convertRPN2Infix(tblinfo(simplify(toRPN("0+"..input))),true) -- true is for isFinal
					end
					debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))
					
					rawResult = finalRes
					
					if improvedRPN ~= finalRes or colorize(improvedRPN) == colorize(input) then prettyDisplay(finalRes) end
				else
					debugPrint("   Direct Calculation via lua math engine.")
					rawResult = finalRes
					prettyDisplay(finalRes)
				end
			end
			
					
			io.write("\n")
			io.flush()
			
			chgFlag = 0
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
