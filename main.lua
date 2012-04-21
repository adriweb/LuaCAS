dofile 'tools.lua'
dofile 'rpn.lua'
dofile 'simple.lua'
dofile 'rpn2infix.lua'

repeat
	io.write("luaCAS> ")
	io.flush()
	local input=io.read()
   	if input:len()>0 then
   		print("   RPN expr is : " .. tblinfo(toRPN(input)) or "error")
   		print("   Maybe improved input : " .. convertRPN2Infix(tblinfo(toRPN("0+" .. input))):sub(3) or "error") -- hacky but works
   		local simprpn = tblinfo(simplify(toRPN(input)))
		print("   RPN expr of simplified is : " .. simprpn or "error")
		print("   Calculated RPN is " .. calculateRPN(simprpn) or "error")
		print("   Simplified infix from RPN is : " .. convertRPN2Infix(simprpn) or "error")
		io.write("\n")
		io.flush()
	end
until input=="quit" or input=="exit"
