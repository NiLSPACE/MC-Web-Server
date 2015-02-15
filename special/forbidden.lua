<?lua
local Client, Link = ...

local RequestPath = Client.RequestPath

?>
<!DOCTYPE html>
<html>
<head>
	<title>403 Forbidden</title>
</head>

<body>
	<h1>Forbidden</h1>

	You don't have permission to acces <?lua Link:Send(RequestPath) ?> on this server
	<hr>
	<address>MC-Web-Server</address>
</body>
</html>