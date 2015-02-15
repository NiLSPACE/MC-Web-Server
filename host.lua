




local LinkCallbacks =
{
	OnConnected = function (a_TCPLink)
		-- Nothing here
	end,
	
	OnError = function (a_TCPLink, a_ErrorCode, a_ErrorMsg)
		-- Stuff
	end,
	
	OnReceivedData = function (a_TCPLink, a_Data)
		local Client = cClient(a_Data, a_TCPLink)
		
		local FullPath = g_Config.WebPath .. Client.RequestPath
		
		local Status = "HTTP/1.0 200 OK" 
		
		local Forbidden = false
		local PathPos = 0 -- If this becomes negative then the path is outside
		local PathParts = StringSplit(Client.RequestPath)
		for I, PathPart in ipairs(PathParts) do
			local PathDirection = 1
			if (PathPart == "..") then
				PathDirection = -1
			elseif (PathPart == ".") then
				PathDirection = 0
			end
			PathPos = PathPos + PathDirection
		end
		
		if (PathPos < 0) then
			-- Path is outside the webpages folder. Forbid it
			Forbidden = true
			Status = "HTTP/1.0 403 Forbidden"
			FullPath = g_Config.SpecialPath .. "forbidden.lua"
		end
		
		if (not Forbidden) then
			if (not cFile:Exists(FullPath) and not cFile:IsFolder(FullPath)) then
				Status = "HTTP/1.0 404 Not Found"
				FullPath = g_Config.ErrorPath .. "/404.lua"
			end
			
			if (cFile:IsFolder(FullPath)) then
				if (not cFile:Exists(FullPath .. "/index.lua")) then
					FullPath = g_Config.SpecialPath .. "/folder.lua"
				else
					FullPath = FullPath .. "/index.lua"
				end
			end
		end
		
		-- Send the status
		Client:Header(Status)
		Client:Header("Server: MC-Web-Server/" .. g_Plugin:GetVersion() .. " " .. _VERSION:gsub(" ", "/"))
		
		local File = io.open(FullPath, "r")
		local Content = File:read("*all")
		File:close()
		
		local LuaCode = Content
		local Patterns = {"%?>.-<%?lua", "%?>.-$", "^.-<%?lua"} -- Patterns used to comment out html code
		
		-- Find all the Lua code pieces and separate them with a coroutine.yield function.
		for Idx, pattern in ipairs(Patterns) do
			LuaCode = LuaCode:gsub(pattern,
				function (a_Str)
					a_Str = a_Str:sub(3, -6)
					return ' coroutine.yield() --[[' .. a_Str .. ' ]]'
				end
			)
		end
		
		Content = Content:gsub("<??lua.-???>", 
			function(a_Str)
				a_Str = a_Str:sub(6, -3)
				return ("<?lua" .. '' .. "?> ")
			end
		)
		
		local LuaProgram, Err = loadstring(LuaCode)
		if (not LuaProgram) then
			-- Error occured. Send an error message and close the connection
			LOGWARNING("Something went wrong in " .. FullPath)
			a_TCPLink:Send(ComposeHTMLError("Parse error: " .. Err))
			
			a_TCPLink:Shutdown()
			return
		end
		
		LuaProgram = coroutine.create(LuaProgram)
		coroutine.resume(LuaProgram, Client, a_TCPLink)
		
		local MinPos = 0
		local MaxPos = Content:find("<??lua")
		while (MaxPos ~= nil) do
			local Min = Clamp(MinPos + 3, 1, Content:len())
			local Max = Clamp(MaxPos - 1, 1, Content:len())
			
			-- Send all the non-lua code
			a_TCPLink:Send(Content:sub(Min, Max))
			
			-- Find the next lua tags
			MinPos = Clamp(Content:find("??>", MaxPos), 0, Content:len())
			MaxPos = Content:find("<??lua", MinPos)
			
			-- Check if the code already stopped. This can happen because of an error in the code or the code simply returned.
			if (coroutine.status(LuaProgram) ~= 'dead') then
				-- Execute the next lua code
				local Success, Err = coroutine.resume(LuaProgram, Client, a_TCPLink)
				if (not Success) then
					a_TCPLink:Send(ComposeHTMLError(Err, LuaProgram))
					break
				end
			end
		end
		
		-- Send the remaining text
		a_TCPLink:Send(Content:sub(MinPos + 3, Content:len()))
		
		-- Make sure the program always finishes
		while (coroutine.status(LuaProgram) ~= 'dead') do
			coroutine.resume(LuaProgram)
		end
		
		a_TCPLink:Shutdown()
	end,
	
	OnRemoteClosed = function (a_TCPLink)
		-- Stuff
	end
}



local ListenCallbacks =
{
	OnAccepted = function(a_TCPLink)
		-- Stuff
	end,
	
	OnError = function(a_ErrorCode, a_ErrorMsg)
		-- Stuff
	end,
	
	OnIncomingConnection = function(a_RemoveIP, a_RemotePort, a_LocalPort)
		return LinkCallbacks
	end
}

function StartWebHost()
	local Port = g_Config.Port or 80
	
	Server = cNetwork:Listen(Port, ListenCallbacks)
end