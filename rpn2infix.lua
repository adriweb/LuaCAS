makeNumberNode = function (number)
    local node = {
        kind  = "number",
        value = number
    }
    return node
end

makeVariableNode = function (var)
	local node = {
        kind  = "variable",
        value = var
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
    local stack = {}
    local i=0, ch, rhs, lhs
    
    while i<string.len(rpnExpr) do
    	i=i+1
    	local j = i
    	ch = ""
    	while " "~=(string.sub(rpnExpr,j,j)) and j <= string.len(rpnExpr) do
        	ch = ch .. string.sub(rpnExpr,j,j);
        	j=j+1
        end
        if ch~=" " and ch ~= "" then
			if isNumeric(ch) then
				stackPush(stack,makeNumberNode(ch));
			elseif string.find("*-+/^",ch) then
				rhs = stackPop(stack);
				lhs = stackPop(stack);
				stackPush(stack,makeOpNode(ch, lhs, rhs));
			else
				stackPush(stack,makeVariableNode(ch));
			end
			if i+string.len(ch) > string.len(rpnExpr) then
        		i=i+1
    		else
    			i=i+string.len(ch)
    		end
        end
    end        
        
    return stackPop(stack);
end
    
needParensOnLeft = function (node)
    return ((node.left.kind == "operator") and
            (node.left.precedence < node.precedence));
end
    
needParensOnRight = function (node)
    if (node.right.kind == "number" or node.right.kind == "variable") then
        return false;
    end
    if ((node.operator == "+") or (node.operator == "*")) then
        return true--(node.right.precedence < node.precedence);
    end
    return true--(node.right.precedence <= node.precedence);
end
    
visit = function (node)
    if node.kind=="number" or node.kind=="variable" then
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
    --dump("tree",tree)
    local infixExpr = tree and visit(tree) or "error";
    return infixExpr
end
