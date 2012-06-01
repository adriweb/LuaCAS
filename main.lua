-------------------------------------
----            LuaCAS           ----
----             v1.0            ----
----                             ----
----  Adrien 'Adriweb' Bertrand  ----
----       Alexandre Gensse      ----
----             2012            ----
----                             ----
----         GPL License         ----
-------------------------------------

dofile'other.lua'
dofile'tools.lua'
dofile'rpn.lua'
dofile'simple.lua'
dofile'rpn2infix.lua'
dofile'commands.lua'

rawResult = ""
timeStart = 0
timeEnd = 0

function main()
    while input ~= "exit" do
        io.write("luaCAS> ")
        io.flush()
        input = io.read()
        timeStart = os.time()
        outputStack = {}
        if input:len() > 0 then
            if input ~= input:gsub("(Ans)", rawResult) then
                input = input:gsub("(Ans)", rawResult)
                chgFlag = 1
            end

            input = symbolify(input)
            
            globalInput = input
			
            _, finalRes = pcall(loadstring("return " .. input) or function() end)
            -- finalRes will contain the result if possible.

            if not checkCommand(input) then
                if type(finalRes) ~= "number" then
                    debugPrint("   Direct Calculation (via lua math engine) not possible.")
                    debugPrint("   RPN expr is : " .. tblinfo(toRPN(input)))

                    local improvedRPN = convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3)
                    improvedRPN = convertRPN2Infix(tblinfo(toRPN(input)))
                    if colorize(improvedRPN) ~= colorize(input) and chgFlag == 0 then prettyDisplay(improvedRPN) end
					
					timeStart = os.time()
                    local simprpn = tblinfo(simplify(toRPN(input)))
                    globalRPN = simprpn
                    debugPrint("   RPN expr of simplified is : " .. colorize(simprpn))
                    debugPrint("   Calculated RPN is " .. colorize(calculateRPN(simprpn)))

                    if calculateRPN(simprpn) == "var error" then
                        debugPrint("   got variable error in calculateRPN!")
                        finalRes = convertRPN2Infix(simprpn)
                    else
                        --print("this should never appear ? (main:57). simprpn was = ", simprpn)
                        --finalRes = convertRPN2Infix(tblinfo(simplify(toRPN("0+" .. input))))
                    end
                    debugPrint("   Simplified infix from RPN is : " .. colorize(finalRes))
					
					timeEnd = os.time()
					
                    rawResult = finalRes
					prettyDisplay(finalRes)

                else
                    debugPrint("   Direct Calculation (via lua math engine).")
                    rawResult = finalRes
                    outputStack = {}
                    prettyDisplay(finalRes)
                end
                
                cleanOutputStack()
				--rawResult = outputStack[#outputStack] or "NoResult"
				
			else 
				rawResult = "NoResult"
            end
				
			unpackOutputStack()
        	outputStack = {}

			print(timeEnd-timeStart .. " sec.")

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
        if string.len(theErr) > 5 then print("", colors.onred .. "Error ! " .. colors.reset .. " " .. theErr) print("") end
        launch()
    end
end

print(getAbout())

launch()
