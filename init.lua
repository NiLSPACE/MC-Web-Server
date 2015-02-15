



g_Plugin = nil
g_Config = -- TODO: Put this in a different file
{
	Port = 81,
	WebPath = "Plugins/MC-Web-Server/www",
	ErrorPath = "Plugins/MC-Web-Server/errors",
	SpecialPath = "Plugins/MC-Web-Server/special"
}




function Initialize(a_Plugin)
	a_Plugin:SetName("MC-Web-Server")
	a_Plugin:SetVersion(1)
	g_Plugin = a_Plugin
	
	StartWebHost()
	
	LOG("WebServer is initializing")
	return true
end




function OnDisable()
	LOG("WebServer is shutting down")
	Server:Close()
end