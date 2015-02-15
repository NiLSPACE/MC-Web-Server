




function RemoveHTMLEntities(a_String)
	a_String = a_String:gsub("<", "&lt;")
	a_String = a_String:gsub(">", "&gt;")
	
	return a_String
end



function string.random(a_CharSet, a_Length)
	local Str = ''
	
	for I = 1, a_Length do
		local CharPos = math.random(1, a_CharSet:len())
		Str = Str .. a_CharSet:sub(CharPos, CharPos)
	end
	
	return Str
end



function string.ucfirst(a_String)
	local firstChar = a_String:sub(1, 1):upper()
	local Rest = a_String:sub(2)
	
	return firstChar .. Rest
end



function ComposeHTMLError(a_Err, a_Thread)
	local res = '\n<table border="1" >\n\t<tr><td colspan="2" style="padding: 2px; background-color: #DF0101; border: 1px solid black;">'
	a_Err = a_Err:gsub("%[.-%]", function(a_Str) return '' end):gsub(":%d+: ", "")
	a_Err = a_Err:ucfirst()
	
	res = res .. a_Err .. "</td></tr>"
	
	if (a_Thread) then
		res = res .. '\n\t<tr><td colspan="2" style="padding: 2px; border: 1px solid black; background-color: #F57900">Call Stack</td></tr>'
		res = res .. '\n\t<tr><td style="text-align: center; border: 1px solid black; background-color: #eeeeec">#</td><td style="padding: 2px; border: 1px solid black; background-color: #eeeeec">Function</td></tr>'
		local Stack = debug.traceback(a_Thread)
		local Errors = StringSplit(Stack, "\n")
		
		table.remove(Errors, 1) -- First line is "stack traceback:"
		
		for I, line in ipairs(Errors) do
			while (line:find("\t") ~= nil) do
				line = line:gsub("\t", "")
			end
			
			line = line:gsub("%[.-%]", function(a_Str) return '' end):gsub(":%d+: ", "")
			line = line:ucfirst()
			res = res .. '\n\t<tr><td style="text-align: center; border: 1px solid black; background-color: #eeeeec">' .. I .. '</td>'
			res = res .. '\n\t<td style="padding: 2px; border: 1px solid black; background-color: #eeeeec">' .. line .. '</td></tr>'
		end
	end
	
	res = res .. '\n</table>'
	return res
end