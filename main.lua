dofile 'tools.lua'
dofile 'rpn.lua'
dofile 'simple.lua'
dofile 'rpn2infix.lua'

repeat
	io.write("luaCAS> ")
	io.flush()
	input=io.read()
   	if input:len()>0 then
   		print("   RPN expr is : " .. tblinfo(toRPN(input)))
   		local simprpn = tblinfo(simplify(toRPN(input)))
		print("   RPN expr of simplified is : " .. simprpn)
		print("   Calculated RPN is " .. calculateRPN(simprpn))
		print("   Simplified infix from RPN is " .. convertRPN2Infix(simprpn) or "error")
		io.write("\n")
		io.flush()
	end
until input=="quit" or input=="exit"
