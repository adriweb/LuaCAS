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

require('LuaXml')

function url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

-- load XML data from file "test.xml" into local table xfile

function getWolframResult(input)

	app_id = "8VJEEW-68A6487LYH"
	
	url = '"http://api.wolframalpha.com/v2/query?appid=' .. app_id .. '&input='.. url_encode(input) .. '&format=plaintext"'
	
	os.execute("curl --silent " .. url .. " > /Users/Adrien/Documents/text.xml")
	
	debugPrint("Wolfram|Alpha API Request : " .. url)
	local xfile = xml.load("/Users/Adrien/Documents/text.xml")
	-- search for substatement having the tag "pod"
	local resultPod = xfile:find("pod","title","Result")
	local theResultThing
	if resultPod then 
		theResultThing = resultPod:find("plaintext")
	else
		resultPod = xfile:find("subpod","title")
		if resultPod then 
			theResultThing = resultPod:find("plaintext")
			if not theResultThing then return input end
			local egalIndex = theResultThing[1]:find("%s=%s") or 0
			if egalIndex ~= 0 then
				egalIndex = egalIndex+3
			end
			theResultThing[1] = theResultThing[1]:sub(egalIndex)
		end
	end

	return theResultThing and theResultThing[1] or input

end
