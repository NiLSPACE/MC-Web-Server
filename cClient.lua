




g_Sessions = {}




function cClient(a_Header, a_TCPLink)
	local self = {}
	
	local SplitHeader = StringSplit(a_Header, "\n")
	
	local RequestLine = StringSplit(SplitHeader[1], " ")
	
	self.RequestMethod   = RequestLine[1]
	self.RequestPath     = (RequestLine[2] == "/" and "/index.lua") or RequestLine[2]
	self.FullPath        = g_Config.WebPath .. self.RequestPath
	self.ProtocolVersion = RequestLine[3]
	
	table.remove(SplitHeader, 1)
	
	
	local m_SessionID = '';
	self.HEADER = {}
	
	-- Check for the headers and save them in a table
	for _, Line in ipairs(SplitHeader) do
		if (Line == "") then
			-- Post values are usualy after an empty line. We don't want that in the header
			break
		end
		
		local Pos = Line:find(":")
		
		if (not Pos) then
			break
		end
		
		local Type = Line:sub(1, Pos - 1)
		local Value = Line:sub(Pos + 1, Line:len())
		
		-- Save the header
		self.HEADER[Type] = Value
	end
	
	
	self.SESSION = {}
	
	-- Find a session
	if (self.HEADER['Cookie'] ~= nil) then
		local Cookies = StringSplit(self.HEADER['Cookie'], " ")
		for I, Val in ipairs(Cookies) do
			local CookieInfo = StringSplit(Val, "=")
			if (CookieInfo[1] == "PHPSESSID") then
				m_SessionID = CookieInfo[2]
				self.SESSION = g_Sessions[m_SessionID] or {}
				g_Sessions[CookieInfo[2]] = self.SESSION
			end
		end
	end
	
	self.POST = {}
	self.GET  = {}
	
	-- Fill the GET or POST tables depending on the request method
	if (self.RequestMethod == "GET") then
		local GetString = StringSplit(self.RequestPath, "?")
		GetString = StringSplit(GetString[2] or "", "&") -- GetString[1] is the url/file while GetString[2] is the get value

		for _, V in ipairs(GetString) do
			local SingleGet = StringSplit(V, "=")
			self.GET[SingleGet[1]] = SingleGet[2]
		end
	elseif (self.RequestMethod == "POST") then
		local PostString = SplitHeader[#SplitHeader]
		PostString = StringSplit(PostString or "", "&")
		
		for _, V in ipairs(PostString) do
			local SinglePost = StringSplit(V, "=")
			self.POST[SinglePost[1]] = SinglePost[2]
		end
	else
		LOGWARNING("Unknown request method")
	end
	
	function self:Header(a_Str)
		a_TCPLink:Send(a_Str .. "\n")
	end
	
	function self:RegenerateSessionID()
		local Chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		local NewID = Chars:random(26)
		
		g_Sessions[NewID] = g_Sessions[m_SessionID]
		g_Sessions[m_SessionID] = nil
		m_SessionID = NewID
		
		self:Header("Set-Cookie: PHPSESSID=" .. NewID .. "; path=/")
	end
	
	function self:GetSessionID()
		return m_SessionID
	end
	return self
end
	