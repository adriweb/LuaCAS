lesgroupes = {}
i = 1
while i ~= 0 do
	i = findNextPlus(rpn)
	cptgrp = 1
	compteur = 2
	while compteur ~= 0 do
		i = i-1
		lesgroupes[cptgrp] = rpn[i] .. " " .. lesgroupes[cptgrp]
		if operator[rpn[i]] then
			compteur = compteur+2
		else
			cptgrp = cptgrp + 1
		end
		compteur = compteur - 1
	end
end

function findNextPlus(rpn)
	for k,v in pairs(rpn) do
		if v == "+" then return k end
	end
	return 0 -- probleme....
end
