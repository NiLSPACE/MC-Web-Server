<?lua
local Client, Link = ...

local RequestPath = Client.RequestPath

?>
<!DOCTYPE html>
<html>
<head>
	<title>404 Not Found</title>
</head>

<body>
	<h1>Not Found</h1>
		The requested URL <?lua Link:Send(RequestPath) ?> was not found.
	<hr>
	<address>MC-Web-Server</address>
</body>
</html>