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
-- Parts also by Jim Bauwens

dofile"other.lua"

needReSimplify = false
possibleCommut = {}
doneCommut = {}
alreadyCommut = {}
commutList = {}
possibleCommut = {}
alreadyPassed = 0
rpnSave = {}

function areNumeric(a, b)
    return isNumeric(a) and isNumeric(b)
end

function isClean(n)
    return math.floor(n) == n
end

function div(a, b)
    if areNumeric(a, b) then
        local sol = a / b
        if isClean(sol) then
            return true, sol
        elseif isClean(a) and isClean(b) then
            for i = math.min(a, b), 2, -1 do
                if isClean(a / i) and isClean(b / i) then
                    a = a / i
                    b = b / i
                    break
                end
            end
            return false, a, b
        else
            return false, a, b
        end
    end
end

function simplify3(rpn)	
	--rpn = copyTable(replaceNegative(rpn))
    rpn = copyTable(simpleFactor(rpn))
    rpn = copyTable(calculateNumericalCoeff(rpn))  -- 5 1 +  ->  6
    rpn = copyTable(create1x(rpn))
    rpn = copyTable(replaceP(rpn))
    rpn = copyTable(simpleFactor(rpn))
    rpn = copyTable(simpleFactorTheRemix(rpn))
    rpn = copyTable(deleteUseless(rpn))
	rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
	
    if needReSimplify then
        rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
        rpn = copyTable(simplify2(rpn))
    end
    rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
    return rpn
end

function simplify2(rpn)
    --rpn = copyTable(replaceNegative(rpn))
    rpn = copyTable(simpleFactor(rpn))
    rpn = copyTable(calculateNumericalCoeff(rpn))  -- 5 1 +  ->  6
    rpn = copyTable(create1x(rpn))
    rpn = copyTable(replaceP(rpn))
    rpn = copyTable(trySimplifyRpn(rpn))
    rpn = copyTable(simpleFactor(rpn))
    rpn = copyTable(simpleFactorTheRemix(rpn))
    rpn = copyTable(deleteUseless(rpn))
	rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
	
    if needReSimplify then
        rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
        rpn = copyTable(simplify2(rpn))
        return rpn
    end

    rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
    if alreadyPassed == 0 then alreadyPassed = 1 needReSimplify = false simplify2(rpn) end

    return rpn
end

function simplify(rpn)

    isSimplifying = 0
    needReSimplify = true
    rpn = copyTable(alphabetize(rpn))
	debugPrint("   Alphabetizing expression")
	stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn)))
    rpn = simplify2(rpn)

    needReSimplify = true

    local perfectRpn = copyTable(rpn)
    perfectRpn = copyTable(calculateNumericalCoeff(rpn))
	local compteurdemerde = 0
    while needReSimplify do
		compteurdemerde = 1
        --rpn = calculateNumericalCoeff(rpn)
        debugPrint("	Entering simplify's commut find loop with rpn : ", tblinfo(rpn))
        if findNextPlus(rpn) == 0 then
            perfectRpn = copyTable(simpleFactor(rpn))
            break
        end

        local perfectRpn = detectCommutGroup(rpn)
        
        --listRpn = createPossibleRpnTable(rpn, commutList2)
        
        --[[for k, v in pairs(listRpn) do
            v = create1x(v)
			newV = {}
            newV = copyTable(simplify3(v))
            newV = copyTable(simplify3(newV))
            v = create1x(v)
            newV = create1x(newV)
            if (numberOfMult(newV) < numberOfMult(v)) then
				v = deleteUseless(v)
				newV = deleteUseless(newV)
                perfectRpn = copyTable(newV)
                needReSimplify = true
                break
            	else needReSimplify = false
            	end
        	end]]--
        rpn = copyTable(perfectRpn)
    end
	
	perfectRpn = copyTable(calculateNumericalCoeff(perfectRpn))
	perfectRpn = copyTable(deleteUseless(perfectRpn))
    perfectRpn = copyTable(alphabetize(perfectRpn))
    return perfectRpn
end

function infixSimplify(infix)
    return infix
end

function create1x(rpn, start)
    local oldrpn = copyTable(rpn)
    local token
    for i = (start or 1), #rpn do
        token = rpn[i]
        if strType(token) == "variable" then
            if (not ((strType(rpn[i + 1]) == "numeric" or strType(rpn[i + 1]) == "variable") and (rpn[i + 2] == "*" or rpn[i + 2] == "/"))) and ((i + 1 > #rpn) or (rpn[i + 1] ~= "*" and rpn[i + 1] ~= "/")) then
                table.remove(rpn, i)
                table.insert(rpn, i, "1")
                table.insert(rpn, i + 1, token)
                table.insert(rpn, i + 2, "*")
            end
            create1x(rpn, i + 2)
            break
        end
    end
    if isSimplifying == 1 and convertRPN2Infix(tblinfo(rpn)) ~= input then stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn))) end
    isSimplifying = isSimplifying + 1
    if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
    return rpn
end

function deleteUseless(rpn, start)
    local oldrpn = copyTable(rpn)
    local token

    for i = (start or 2), #rpn do
        token = rpn[i]
        if strType(token) == "variable" or strType(token) == "numeric" then
            if rpn[i - 1] == "1" and rpn[i + 1] == "*" then
                table.remove(rpn, i + 1)
                table.remove(rpn, i - 1)
            end
            deleteUseless(rpn, i + 1)
            break
        end
        if strType(token) == "variable" or strType(token) == "numeric" then
            if rpn[i - 1] == "0" and rpn[i + 1] == "*" then
                table.remove(rpn, i + 1)
                table.remove(rpn, i)
                table.remove(rpn, i - 1)
            end
            deleteUseless(rpn)
            break
        end
        if strType(token) == "operator" then
            if token == "/" and rpn[i - 1] == "1" then
                table.remove(rpn, i)
                table.remove(rpn, i - 1)
            end
            deleteUseless(rpn, i + 1)
            break
        end
    end
    return rpn
end

function replaceP(rpn)
    local len = #rpn
    local a, b, o1, o2
    for i = 1, len - 4 do
        a = rpn[i]
        b = rpn[i + 1]
        o1 = rpn[i + 2]
        o2 = rpn[i + 3]

        if not operator[a] and not operator[b] and operator[o1] and operator[o2] and o1 == o2 then
            rpn[i + 1] = o1
            rpn[i + 2] = b
        end
    end

    return rpn
end

function calculateNumericalCoeff(rpn, offs)
    mstable(rpn)
    local len = #rpn
    local token
    local op

    local pos
    for i = (offs or 1), len do
        a = rpn[i]
        b = rpn[i + 1]
        o = rpn[i + 2]
        if not operator[a] and not operator[b] and operator[o] then
            pos = i
            op = o
            break
        end
    end

    if pos then
        local j = 0
        for i = pos + 3, len do
            j = j + 1
            if not (op == rpn[i] and not operator[rpn[pos - j]]) then
                j = j - 1
                break
            end
        end

        local done, off = simpgroup(rpn, pos - j, pos + 2 + j, op)
        calculateNumericalCoeff(rpn, off)
        return rpn
    else
        return rpn
    end
end

function creategroup(datatable, operator, startgroup)-- Create a new RPN valid group from data values. startgroup ('a') is need to fix the previous RPN group
    local group = {}

    group[1] = startgroup or table.remove(datatable, 1)

    for _, value in ipairs(datatable) do
        table.insert(group, tostring(value)) -- tostring to be sure all data is in strings when we put it back in the RPN table
        table.insert(group, operator)
    end

    return group
end

function simpgroup(rpn, posa, posb, o, startgroup)-- Simplify the group. If startgroup is not nil, then it is part of a previous RPN group

    local len = #rpn
    local n = posb - posa -- The length of the RPN group we are handling
    local datatable = {}

    -- We might need to find another solution.
    local oldrpn = copyTable(rpn)

    -- We need to handle these stuff different. This is for later, as currently they can give faulty results
    -- We should change add negative sign's to numbers and create a special rational number type
    if o == "/" or o == "-" or o == "^" then
        return false, posb + 1 -- needs fixing :D #TODO
    end

    -- Remove the ENTIRE (and possible the last operator of the previous RPN group) and put the datavalues in a separate table
    local d
    for i = posa, posb do
        d = table.remove(rpn, posa)
        if not operator[d] then
            table.insert(datatable, d)
        end
    end
    -- Sort the table, so we can easily simplify it
    table.sort(datatable) -- sort the datatable

    -- combine numbers together
    local n1, n2

    while tonumber(datatable[1]) and tonumber(datatable[2]) do
        datatable[1] = operator[o][3](datatable[1], table.remove(datatable, 2))
    end

    -- create a RPN valid group of the remaining data values
    local group = creategroup(datatable, o, startgroup)

    -- Reinsert the group into our RPN table
    for k, value in ipairs(group) do
        table.insert(rpn, posa + k - 1, value)
    end

    return not compareTable(oldrpn, rpn), posa + #group - 1
end

function findgroup(rpn, pos, ro)
    local len = #rpn
    local posa = pos

    if len < pos + 3 then
        return pos + 2
    end

    local c, o
    local out = pos + 2
    for i = pos + 3, len - 1, 2 do
        out = i + 1
        c = rpn[i]
        o = rpn[i + 1]

        if o ~= ro or operator[c] then
            return i - 1
        end
    end

    return out
end

function alphabetize(rpn)
    mstable(rpn)
    local len = #rpn
    local cgroup = {}
    local breakuntil = 0

    for i = 1, len - 2 do
        if breakuntil > i then
            break
        end

        local a = rpn[i]
        local b = rpn[i + 1]
        local o = rpn[i + 2]
        if not operator[b] and operator[o] then

            -- Alright, we look for the start of a new group. 'a' CAN be an operator of a group before that.
            -- We use it determine the group type we detected. We may never lose 'a', as it is needed for correct RPN
            -- Example group if 'a' is an operator:
            -- * 9 + 6 +
            -- If 'a' is not an operator
            -- 8 9 + 6 +
            -- We can simplify both groups, but we need to take 'a' in account

            -- Find the group
            local posb = findgroup(rpn, i, o)

            -- Simplify (if it can) the group.
            local done = simpgroup(rpn, i, posb, o, operator[a] and a)
            -- If there are changes, try to simplify it again. This is currently recursive, should change to non-recursive.
            if done then
                alphabetize(rpn)
                break
            end
        end
    end

    return rpn
end

function simpleFactor(rpn, start)

    local i = start or 1
    local oldrpn = copyTable(rpn)

	--print("simpleFactor with rpn : ", tblinfo(rpn))

    -- TODO  :   algo simplification pour fractions avec haut == bas  ( -> 1)
    while i < #rpn - 5 do -- minimum required to perform any factorization ([coeff1][insideOP1][var][globalOP][coeff2][insideOP2][var])
        -- which is in RPN : [coeff1][var][insideOP1][coeff2][var][insideOP2][globalOP]
        -- let's find in the RPN stack the place where there are two operators in a row.
        -- The one at the end will be the global op and the one before will be the inside one.
        insideOP2 = rpn[i + 5]
        insideOP1 = rpn[i + 2]
        globalOP = rpn[i + 6]
        coeff1 = rpn[i]
        coeff2 = rpn[i + 3]
        var1 = rpn[i + 1]
        var2 = rpn[i + 4]
        if strType(insideOP2) == "operator" and strType(globalOP) == "operator" then
            if (insideOP1 == insideOP2) and insideOP1 ~= "^" and globalOP ~= "/" and globalOP ~= "^" then
                -- Get coefficients for the each inner part
                -- Check for good (expected) types.
                if strType(coeff1)~="operator" and strType(coeff2)~="operator" then
                    -- Get the variables for each coeff. Then check if it's the same variables we're dealing with.
                    if var1 == var2 and strType(var1) ~= "operator" then
                        debugPrint("   simpleFactorisation possible. Doing it.  rpn = ", tblinfo(rpn))
                        debugPrint("   Possible to factor : " .. coeff1 .. " " .. insideOP1 .. " " .. var1 .. " " .. globalOP .. " " .. coeff2 .. " " .. insideOP2 .. " " .. var2)
                        debugPrint("   Inside the RPN : " .. tblinfo(rpn))
                        -- Well, it's all good ! Let's factor all that.
                        -- in infix : [(][coeff1][globalOP][Coeff2][)][insideOP][Variable1]
                        -- in RPN : [coeff1][coeff2][globalOP][var][insideOP1]
                        rpn[i + 1] = coeff2
                        rpn[i + 2] = globalOP
                        rpn[i + 3] = var1
                        rpn[i + 4] = insideOP1
                        table.remove(rpn, i + 5)
                        table.remove(rpn, i + 5)
                        stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn)))
                        rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
                    end
                end
            end
        end
        rpn = calculateNumericalCoeff(rpn)
        i = i + 1
    end

	if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
    return rpn
end

function simpleFactorTheRemix(rpn, start)
		local i = start or #rpn
		local oldrpn = copyTable(rpn)
		while i > 6 do -- minimum required to perform any factorization ([coeff1][insideOP1][var1][globalOP][coeff2][insideOP2][var2])     2*x+3*x
			-- which is in RPN : [coeff1][var][insideOP1][coeff2][var][insideOP2][globalOP]														2x*3x*+
			-- let's find in the RPN stack the place where there are two operators in a row.
			-- The one at the end will be the global op and the one before will be the inside one.
			globalOP = rpn[i]
			if strType(globalOP) == "operator" and globalOP ~= "/" and globalOP ~= "^" then
				var2 = rpn[i-2]
				insideOP2 = rpn[i-1]
				if insideOP2 ~= "^" and (strType(var2) == "variable" or strType(var2) == "numeric") and strType(insideOP2) == "operator" then
					coeff2 = rpn[i-3]
					k1 = 1
					if (strType(coeff2) ~= "numeric" and strType(coeff2) ~= "variable") and strType(coeff2) == "operator" then
					--k1 = 1
					isOk = 2
					coeff2 = rpn[i-3] .. " "
						while isOk ~= 0 and i-3-k1 > 3 do
						coeff2 = rpn[i-3-k1] .. " " .. coeff2
							if strType(rpn[i-3-k1]) == "operator" then
								isOk = isOk + 1
							else isOk = isOk - 1
							end
						k1 = k1 + 1
						end
						if i-3-k1 <= 4 then return rpn end
					else coeff2 = coeff2 .. " "
					end
						var1 = rpn[i-4-k1]
						insideOP1 = rpn[i-3-k1]
						if insideOP1 == insideOP2 and var1 == var2 and (strType(var1) == "variable" or strType(var1) == "numeric") and strType(insideOP1) == "operator" then
							coeff1 = rpn[i-5-k1]
							k2 = 1
							if (strType(coeff1) ~= "numeric" and strType(coeff1) ~= "variable") and strType(coeff1) == "operator" then
							coeff1 = rpn[i-5-k1] .. " "
							--k2 = 1
							isOk = 2
								while isOk ~= 0 and i-5-k1-k2 >= 1 do
								coeff1 = rpn[i-5-k1-k2] .. " " .. coeff1
									if strType(rpn[i-5-k1-k2]) == "operator" then
										isOk = isOk + 1
									else isOk = isOk - 1
									end
								k2 = k2 + 1
								end
								if i-5-k1-k2 < 0 then return rpn end
							else coeff1 = coeff1 .. " "
							end
							debugPrint("   simpleFactorisationRemix possible. Doing it.  rpn = ", tblinfo(rpn))
							debugPrint("   Possible to factorremix : " .. coeff1 .. " " .. insideOP1 .. " " .. var1 .. " " .. globalOP .. " " .. coeff2 .. " " .. insideOP2 .. " " .. var2)
							debugPrint("   Inside the RPN : " .. tblinfo(rpn))
							var1 = var1 .. " "
							globalOP = rpn[i] .. " "
							insideOP1 = insideOP1 .. " "
							local rpnEnd = {}
							for k=i+1,#rpn do
								table.insert(rpnEnd,#rpnEnd+1)
							end
							local rpnEndStr = table.concat(rpnEnd)
							rpnEndStr = rpnEndStr
							local rpnStart = {}
							for k=1,i-5-k1-k2-1 do
								table.insert(rpnStart,#rpnStart+1)
							end
							local rpnStartStr = table.concat(rpnStart)
							if rpntStartStr == "" or rpntStartStr == " " then rpnStartStr = "" else rpnStartStr = rpnStartStr .. "  " end
							local rpnStr = nil--table.concat(rpn)
							rpn = {}
							rpnStr = rpnStartStr .. coeff1 .. coeff2 .. globalOP .. var1 .. insideOP1 .. rpnEndStr
							rpn = copyTable(rpnStr:split())
							stepsPrettyDisplay(convertRPN2Infix(tblinfo(rpn)))
							rpn = toRPN(convertRPN2Infix(tblinfo(rpn)))
							if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
							return rpn
						end
				end
			end
			i = i - 1
		end
		if not compareTable(oldrpn, rpn) then needReSimplify = true else needReSimplify = false end
		return rpn
end

function detectCommutGroup(rpn)

    debugPrint("   Entering the new group detection with rpn : ", tblinfo(rpn))

    rpngroupe = {}
    lesgroupes = {}
    possibleCommut = {}
    commutList = {}
    nbrDeGroupes = 2
    cptgrp = 1
    i = 1
    while i > 0 do
        debugPrint("Inside boucle while commut : " .. i)
        i = findNextPlus(rpn)
        compteur = 2
        while compteur ~= 0 do
            i = i - 1
            if i > 0 then
                if rpn[i] == "+" then -- il a normalement déjà été traité
                    lesgroupes[cptgrp] = lesgroupes[cptgrp - 2] .. lesgroupes[cptgrp - 1] .. "+ " .. (lesgroupes[cptgrp] or "")
                    local lesgroupestables1 = lesgroupes[cptgrp - 2]:split()
                    local lesgroupestables2 = lesgroupes[cptgrp - 1]:split()
                    i = i - #lesgroupestables1 - #lesgroupestables2
                else
                    lesgroupes[cptgrp] = rpn[i] .. " " .. (lesgroupes[cptgrp] or "")
                    if operator[rpn[i]] then
                        compteur = compteur + 2
                    end
                end
            end
            compteur = compteur - 1
            if compteur == 1 then
                cptgrp = cptgrp + 1
                if i ~= 1 then
                    if operator[rpn[i - 1]] then
                        compteur = compteur + 1
                    end
                end
            end
        end
        cptgrp = cptgrp + 1
        for tmp = 1, findNextPlus(rpn) do
            table.remove(rpn, 1)
        end
        lesgroupes = resort(lesgroupes)
        if math.mod(#lesgroupes,2) ~= 0 then
		print("Problem detected !! (simple.lua, detectCommutGroup function, nil value(s) somewhere)")
		--table.remove(lesgroupes,#lesgroupes)
		end -- crappy error-avoider
        lesgroupes[nbrDeGroupes - 1], lesgroupes[nbrDeGroupes] = lesgroupes[nbrDeGroupes], lesgroupes[nbrDeGroupes - 1]
        if lesgroupes[nbrDeGroupes] or lesgroupes[nbrDeGroupes - 1] then
            gr = (lesgroupes[nbrDeGroupes - 1] or "") .. (lesgroupes[nbrDeGroupes] or "") .. "+"
            table.insert(rpn, 1, gr)
        end
        i = findNextPlus(rpn)
        nbrDeGroupes = nbrDeGroupes + 2
    end
    debugPrint("   Fin while commut. rpn = ", tblinfo(rpn))
    local rpnCopy = {}
    for k, v in pairs(rpn) do
        local newV = v:gsub("  ", " ")
        table.insert(rpnCopy, newV:split())
    end
    if #rpnCopy > 1 then
        rpnCopy = copyTable(rpnCopy[2])
    else
        rpntemp = copyTable(rpnCopy[1])
        rpnCopy = nil
        rpnCopy = copyTable(rpntemp)
    end
    local tmpRPN = {}
    for indice = 1, #rpnCopy do
        if rpnCopy[indice] or rpnCopy[indice] ~= "" or rpnCopy[indice] ~= " " then
            table.insert(tmpRPN, rpnCopy[indice])
        end
    end
    rpnCopy = nil
    rpnCopy = copyTable(tmpRPN)

    for k, v in pairs(rpnCopy) do
        if not v then table.remove(rpnCopy[k]) end
    end
    table.remove(rpnCopy, #rpnCopy)
    rpn = nil
    rpn = copyTable(rpnCopy)
    possibleCommut = lookForSimilarVariable(lesgroupes)
	--print("lesgroupes ------->",tblinfo2(lesgroupes))

    return rpn
end

function expand(rpn)
	local oldrpn = copyTable(rpn)
	local i=1

	return rpn
end

function cc(tbl)
    out = ""
    for k, v in pairs(tbl) do
        out = out .. v .. " "
    end
    return out
end

function strType(str)
    if not str then return nil end
    if isNumeric(str) then return "numeric" end
    if string.find("*-+/^", str) then return "operator" end
    if string.find(" ", str) then return "blank" end
    return "variable" -- meh
    -- if string.find("sin",str) then return "function" end    --> do all other cases
end

function replaceNegative(t)
    for i = 1, #t - 1, 1 do
        if strType(t[i]) == "numeric" and t[i + 1] == "-" then
            t[i] = "-"  .. t[i]
            t[i + 1] = "+"
        end
    end
    return t
end

function symbolify(infix)
    string.gsub(infix,"π","pi")  -- do stuff like that but check it's a variable name alone. Not part of a bigger var name.
    return infix
end

function lookForSimilarVariable(lesgroupes)

    local temp1, temp2
    possibleCommut = {}
	--dump("lesgroupes : ", lesgroupes)
    for i = 1, #lesgroupes, 2 do
        --print("lesgroupes i : ", lesgroupes[i])
        --print("lesgroupes i+1 : ", lesgroupes[i+1])
		temp1 = lesgroupes[i]:split()
		temp2 = lesgroupes[i + 1]:split()
		for _, v in pairs(temp1) do
			for _, p in pairs(temp2) do
			   if v and v ~= "" and not operator[v] and possibleCommut[#possibleCommut] ~= i then
				  table.insert(possibleCommut, i)
			   end
			end
		end
    end

    return possibleCommut
end

function generateEachCommmutHelper(possibleCommut, commutList, pos, length, add)
    for i = pos, length do
        local toadd = add .. possibleCommut[i] .. " "
        local rpnsave = copyTable(rpn)
        rpn = rpnCommutRpn(rpn)
        rpn = copyTable(simplify(rpn))
        if (numberOfMult(rpn) < numberOfMult(rpnsave)) then return rpn else rpn = copyTable(rpnsave) end
        generateEachCommmutHelper(possibleCommut, commutList, i + 1, length, toadd)
    end
end

function generateEachCommmut(possibleCommut, rpn)
    local commutList = {}
    table.sort(possibleCommut)
    rpn = generateEachCommmutHelper(possibleCommut, commutList, 1, #possibleCommut, "")
    return rpn
end

function commut(lesgroupes, i, rpn)
    i = tonumber(i)
    local toCommutStart = tostring(lesgroupes[i])
    local toCommutEnd = tostring(lesgroupes[i + 1])

    for k = 1, (toCommutStart:len() + toCommutEnd:len()) do
        toCommutStart = toCommutStart:gsub("   ", "  "):gsub("  ", " ")
        toCommutEnd = toCommutEnd:gsub("   ", "  "):gsub("  ", " ")
    end

    toCommutStart = toCommutStart:split()
    toCommutEnd = toCommutEnd:split()
    local tempRpn = (table.concat(rpn, " "):gsub("  ", " ")):split()

    for k = 1, #toCommutStart - 1 do
        table.insert(tempRpn, #toCommutEnd + #toCommutStart - 1, strReplace(tempRpn[1], "  ", " ")) -- omg fix this .... should be +1, not -1 (it works but we don't know why.....)
        table.remove(tempRpn, 1)
    end
    return tempRpn
end

function createPossibleRpnTable(theRpnSave, commutList)
    local listRpn = {}
    local theRpn = {}

    for _, v in pairs(commutList) do
        theRpn = copyTable(theRpnSave)

        local tempCommutTbl = {}
        for tmpvar = 1, string.len(tostring(v)) do
			tempCommutTbl = v:split()
			table.remove(tempCommutTbl,#tempCommutTbl)
			--dump("tempCommutTbl : ", tempCommutTbl)
        end
        for _, valeur in pairs(tempCommutTbl) do
            theRpn = commut(lesgroupes, valeur, theRpn)
        end
		--print(" ----> theRpn = ",tblinfo(theRpn))
        table.insert(listRpn, theRpn)
        theRpn = nil
    end
    return listRpn
end

function rpnCommutRpn(rpn,commut)
	local theRpn = {}

        local tempCommutTbl = {}
        for tmpvar = 1, string.len(tostring(commut)) do
			tempCommutTbl = commut:split()
			table.remove(tempCommutTbl,#tempCommutTbl)
			--dump("tempCommutTbl : ", tempCommutTbl)
        end
        for _, valeur in pairs(tempCommutTbl) do
            theRpn = commut(lesgroupes, valeur, theRpn)
        end
        return theRpn
end

function numberOfMult(theRpn)
    local compt = 0
    for _, v in pairs(theRpn) do
        if v and v == "*" then compt = compt + 1 end
    end
    return compt
end

function trySimplifyRpn(rpn)
    local oldrpn = {}
    oldrpn = copyTable(rpn)

	if #rpn>8 then
		for i=1,#rpn-8 do
			if rpn[i+3] == "+" and rpn[i+7] == "+" then
				if (strType(rpn[i]) == "variable" or strType(rpn[i]) == "numeric")
				 and (strType(rpn[i+1]) == "variable" or strType(rpn[i+1]) == "numeric")
				  and (strType(rpn[i+4]) == "variable" or strType(rpn[i+4]) == "numeric")
				   and (strType(rpn[i+5]) == "variable" or strType(rpn[i+5]) == "numeric") then
					if rpn[i+2] == "*" and rpn[i+6] == "*" then
						table.insert(rpn,i+7,"+")
						table.remove(rpn,i+3)
						needReSimplify = true
					end
				end
			end
		end
	end
	while needReSimplify do 
		rpn = copyTable(simpleFactor(rpn))
	end
	if not compareTable(oldrpn, rpn) then
		rpn = copyTable(trySimplifyRpn(rpn)) 
	end
	return rpn
end
