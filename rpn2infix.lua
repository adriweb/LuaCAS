-------------------------------------
---- LuaCAS           ----
---- v0.3            ----
---- ----
---- Adrien 'Adriweb' Bertrand  ----
---- 2012            ----
---- ----
---- GPL License         ----
-------------------------------------
-- Lua Port and additions/fixes by Adriweb from : 
-- http://blog.boyet.com/blog/blog/postfix-to-infix-part-2-adding-the-parentheses/
function makeNumberNode(number)
    local node = {
        kind = "number",
        value = number
    }
    return node
end

function makeVariableNode(var)
    local node = {
        kind = "variable",
        value = var
    }
    return node
end

function makeOpNode(op, left, right)
    local precedence = 1
    if (op == "*") or (op == "/") then
        precedence = 2
    end
    local node = {
        kind = "operator",
        operator = op,
        precedence = precedence,
        left = left,
        right = right
    }
    return node
end

function convertRPN2Tree(rpnExpr)
    local stack = {}
    local i = 0, ch, rhs, lhs

    while i < string.len(rpnExpr) do
        i = i + 1
        local j = i
        ch = ""
        while " " ~= (string.sub(rpnExpr, j, j)) and j <= string.len(rpnExpr) do
            ch = ch .. string.sub(rpnExpr, j, j)
            j = j + 1
        end
        if ch ~= " " and ch ~= "" then
            if isNumeric(ch) then
                stackPush(stack, makeNumberNode(ch))
            elseif string.find("*-+/^", ch) then
                rhs = stackPop(stack)
                lhs = stackPop(stack)
                stackPush(stack, makeOpNode(ch, lhs, rhs))
            else
                stackPush(stack, makeVariableNode(ch))
            end
            if i + string.len(ch) > string.len(rpnExpr) then
                i = i + 1
            else
                i = i + string.len(ch)
            end
        end
    end

    return stackPop(stack)
end

function needParensOnLeft(node)
    return (node.left.kind == "operator") and (node.left.precedence < node.precedence)
end

function needParensOnRight(node)
    if (node.right.kind == "number" or node.right.kind == "variable") then
        return false
    end
    if (node.operator == "+" or node.operator == "*") then
        return node.right.precedence < node.precedence
    end
    return node.right.precedence <= node.precedence
end

function visit(node)
    if node.kind == "number" or node.kind == "variable" then
        return node.value
    end

    local lhs = visit(node.left)
    if needParensOnLeft(node) then
        lhs = '(' .. lhs .. ')'
    end

    local rhs = visit(node.right)
    if needParensOnRight(node) then
        rhs = '(' .. rhs .. ')'
    end

    return lhs .. node.operator .. rhs
end

function convertRPN2Infix(rpnExpr) -- input and output are strings
    if strType(rpnExpr) == "numeric" then return rpnExpr end
    local tree = convertRPN2Tree(rpnExpr)
    if showTree and showDebug then treeDump("tree", tree) end
    local infixExpr = tree and visit(tree) or "error"
    return infixExpr
end
