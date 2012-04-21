function stackPush(stack,...)
	table.insert(stack,...)
end

function stackPop(stack)
	local lastval = stack[#stack]
	table.remove(stack,#stack)
	return lastval
end

makeNumberNode = function (number)
    local node = {
        kind  = "number",
        value = number
    }
    return node
end
    
makeOpNode = function (op, left, right)
    local precedence = 1;
    if ((op == "*") or (op == "/")) then
        precedence = 2;
    end
    local node = {
        kind       = "operator",
        operator   = op,
        precedence = precedence,
        left       = left,
        right      = right
    }
    return node
end
    
convertRPN2Tree = function (rpnExpr)
     stack = {},
        i,
        ch,
        rhs,
        lhs;
        
    for i=1, string.len(rpnExpr), 1 do
    	print("iteration " .. i)
        ch = string.sub(rpnExpr,i,i);
        if isNumeric(ch) and ((tonumber(ch) >= 0) and (tonumber(ch) <= 9 )) then
            stackPush(stack,makeNumberNode(ch));
        else
            rhs = stackPop(stack);
            lhs = stackPop(stack);
            stackPush(stack,makeOpNode(ch, lhs, rhs));
        end
    end        
        
    return stackPop(stack);
end
    
needParensOnLeft = function (node)
    return ((node.left.kind == "operator") and
            (node.left.precedence < node.precedence));
end
    
needParensOnRight = function (node)
    if (node.right.kind == "number") then
        return false;
    end
    if ((node.operator == "+") or (node.operator == "*")) then
        return (node.right.precedence < node.precedence);
    end
    return (node.right.precedence <= node.precedence);
end
    
visit = function (node)
    if node.kind=="number" then
        return node.value;
    end
        
    local lhs = visit(node.left);
    if (needParensOnLeft(node)) then
        lhs = '(' .. lhs .. ')';
    end
        
    local rhs = visit(node.right);
    if (needParensOnRight(node)) then
        rhs = '(' .. rhs .. ')';
    end
        
    return lhs .. node.operator .. rhs;
end
  
convertRPN2Infix = function (rpnExpr)
    local tree = convertRPN2Tree(rpnExpr);
    print("tree is : ".. type(tree))
    local infixExpr = visit(tree);
    print("****** " .. rpnExpr .. " ==> " .. infixExpr);
end
    
convertRPN2Infix("234//") -- => 2/(3/4)
convertRPN2Infix("23/4/") -- => 2/3/4
convertRPN2Infix("234**") -- => 2*3*4
convertRPN2Infix("23*4*") -- => 2*3*4