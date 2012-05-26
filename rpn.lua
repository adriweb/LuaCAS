-------------------------------------
----            LuaCAS           ----
----             v0.3            ----
----                             ----
----  Adrien 'Adriweb' Bertrand  ----
----             2012            ----
----                             ----
----         GPL License         ----
-------------------------------------
-- This part mainly by Jim Bauwens
-- Shunting-Yard Algorithm

operator = {}
operator["^"] = { 4, 1, function(a, b) return a ^ b end }
operator["*"] = { 3, -1, function(a, b) return a * b end }
operator["/"] = { 3, -1, function(a, b) return a / b end }
operator["+"] = { 1, -1, function(a, b) return a + b end }
operator["-"] = { 1, -1, function(a, b) return a - b end }

func = {}
func["sqrt"] = math.sqrt
func["sin"] = math.sin
func["cos"] = math.cos
func["exp"] = math.exp

argument_seperator = ","

function splitExpr(expr)
    local oper = { "%+", "%-", "%*", "%/", "%^", "%(", "%)", "%w+" }
    for _, o in ipairs(oper) do
        expr = expr:gsub(o, " %1 ")
    end
    local out = expr:gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", ""):split()
    return out
end

function toRPN(expr)

    local rpn_out = {}
    local rpn_stack = {}

    local expr = splitExpr(expr)

    if #expr == 0 then
        error("Invalid expression!")
    end

    local pos = 0
    local token = ""
    while pos < #expr do
        pos = pos + 1
        token = expr[pos]

        -- If the token is a number, then add it to the output
        if tonumber(token) then
            table.insert(rpn_out, token)

            -- If the token is a function, then push it to the stack
        elseif func[token] then
            -- We need a matching left parenthesis
            if expr[pos + 1] ~= "(" then
                error("Attempt to use function as variable!")
            else
                table.insert(rpn_stack, token)
            end

            -- If the token is a function argument separator
        elseif token == argument_seperator then
            while true do
                local stack_token = table.remove(rpn_stack)
                if stack_token == "(" then
                    table.insert(rpn_stack, "(")
                    break
                else
                    table.insert(rpn_out, stack_token)
                    if #rpn_stack == 0 then error("Expected ( before argument separator!") end
                end
            end

        elseif operator[token] then
            local o1 = operator[token]
            while true do
                local stack_token = rpn_stack[#rpn_stack]
                if not stack_token then break end
                local o2 = operator[stack_token]
                if o2 and ((o1[2] == -1 and o1[1] <= o2[1]) or (o1[2] == 1 and o1[1] < o2[1])) then
                    table.insert(rpn_out, table.remove(rpn_stack))
                else
                    break
                end
            end
            table.insert(rpn_stack, token)

            -- If the token is a left parenthesis, then push it onto the stack.
        elseif token == "(" then
            table.insert(rpn_stack, "(")

        elseif token == ")" then

            local stack_token = ""

            while true do
                stack_token = table.remove(rpn_stack)
                if stack_token == "(" then
                    break
                else
                    table.insert(rpn_out, stack_token)
                    if #rpn_stack == 0 then error("Mismatched parentheses!") end
                end
            end

            if #rpn_stack > 0 and func[rpn_stack[#rpn_stack]] then
                table.insert(rpn_out, table.remove(rpn_stack))
            end

            -- must be a variable
        else
            table.insert(rpn_out, token)
        end
    end

    for i = #rpn_stack, 1, -1 do
        token = rpn_stack[i]
        if token == "(" or token == ")" then
            error("Mismatched parentheses!")
        else
            table.insert(rpn_out, token)
        end
    end

    return rpn_out
end


function calculateRPN(s)
    tmpVarRPNCalctb = {}
    tmpVarRPNCalcz = 0
    for tmpVarRPNCalctk in string.gfind(s, '%S+') do
        if string.find(tmpVarRPNCalctk, '^[-+*/]$') then
            if 2 > table.getn(tmpVarRPNCalctb) then tmpVarRPNCalcz = nil break end
            tmpVarRPNCalcy, tmpVarRPNCalcx = table.remove(tmpVarRPNCalctb), table.remove(tmpVarRPNCalctb)
            loadstring('tmpVarRPNCalcz=tmpVarRPNCalcx' .. tmpVarRPNCalctk .. 'tmpVarRPNCalcy')()
        else
            tmpVarRPNCalcz = tonumber(tmpVarRPNCalctk) if tmpVarRPNCalcz == nil then break end
        end
        table.insert(tmpVarRPNCalctb, tmpVarRPNCalcz)
    end
    tmpVarRPNCalcn = table.getn(tmpVarRPNCalctb)
    if tmpVarRPNCalcn == 1 and tmpVarRPNCalcz then return (tmpVarRPNCalcz)
    elseif tmpVarRPNCalcn > 1 or tmpVarRPNCalcz == nil then return ('var error')
    end
end

