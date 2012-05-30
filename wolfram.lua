-------------------------------------
----            LuaCAS           ----
----             v0.3            ----
----                             ----
----  Adrien 'Adriweb' Bertrand  ----
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
	
	print("url = ", url)
	
	os.execute("curl --silent " .. url .. " > /Users/Adrien/Documents/text.xml")
	
	local xfile = xml.load("/Users/Adrien/Documents/text.xml")
	-- search for substatement having the tag "pod"
	local resultPod = xfile:find("pod","title","Result")
	local theResultThing = resultPod:find("plaintext")
	-- if this substatement is found
	if theResultThing ~= nil then
		return theResultThing[1]
	else
		return "Sorry, can't get result"
	end

end
