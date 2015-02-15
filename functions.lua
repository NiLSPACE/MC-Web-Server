




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



function string.strip(a_String)
	while (a_String:sub(1, 1) == " ") do
		a_String = a_String:sub(2, -1)
	end
	
	while (a_String:sub(-1, -1) == " ") do
		a_String = a_String:sub(1, -2)
	end
	
	return a_String
end



function ComposeHTMLError(a_Err, a_Thread)
	local res = '\n<table border="1" >\n\t<tr><td colspan="3" style="padding: 2px; background-color: #DF0101; border: 1px solid black;">'
	a_Err = a_Err:gsub("%[.+%]", "")
	local ErrPos = 0
	
	a_Err = a_Err:gsub(":.+%:", 
		function(a_Str)
			ErrPos = a_Str:sub(2, -2)
			return ""
		end
	)
	
	a_Err = a_Err .. " on line " .. ErrPos
	a_Err = a_Err:strip()
	a_Err = a_Err:ucfirst()
	
	res = res .. a_Err .. "</td></tr>"
	
	if (a_Thread) then
		res = res .. '\n\t<tr><td colspan="3" style="padding: 2px; border: 1px solid black; background-color: #F57900">Call Stack</td></tr>'
		res = res .. '\n\t<tr><td style="text-align: center;" bgcolor="#EEEEEC">#</td><td bgcolor="#EEEEEC" >Function</td><td bgcolor="#EEEEEC">Location</td></tr>'
		local Stack = debug.traceback(a_Thread)
		local Errors = StringSplit(Stack, "\n")
		
		table.remove(Errors, 1) -- First line is "stack traceback:"
		local NumItems = #Errors
		
		local stacks = ''
		for I = NumItems, 1, -1 do
			local line = Errors[I]
			while (line:find("\t") ~= nil) do
				line = line:gsub("\t", "")
			end
			
			line = line:gsub("%[.+%]", "")
			
			local ErrPos = 0
			line = line:gsub(":.+%:", 
				function(a_Str)
					ErrPos = a_Str:sub(2, -2)
					return ""
				end
			)
			
			line = line:ucfirst()
			stacks = '\n\t<td bgcolor="#EEEEEC" border="1">' .. ErrPos .. '</td></tr>' .. stacks
			stacks = '\n\t<td bgcolor="#EEEEEC" border="1">' .. line .. '</td>' .. stacks
			stacks = '\n\t<tr><td align="center" bgcolor="#EEEEEC" border="1">' .. I .. '</td>' .. stacks
		end
		
		res = res .. stacks
	end
	
	res = res .. '\n</table>'
	return res
end