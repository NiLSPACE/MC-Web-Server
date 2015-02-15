<?lua
local Client, Link = ...

Client:RegenerateSessionID()
Client:Header("Location: index.php")
local Message = ""

-- User send a post, so he probably wants to login or logout
if (Client.RequestMethod == "POST") then
	if (Client.POST['logout'] ~= nil) then
		-- The user wants to log out
		Client.SESSION['loggedin'] = false;
		Message = "You logged out"
	elseif (Client.POST['login'] ~= nil) then
		-- The user tries to log in.
		local UserName = Client.POST['username']
		local Password = Client.POST['password']
		
		if (UserName == "admin" and Password == "admin") then
			-- password and username is correct
			Client.SESSION['loggedin'] = true
			Message = "You logged in"
		else
			-- Wrong username or password
			Message = "You used the wrong username or password"
		end
	end
end

function T()
	return nil * 5
end


local IsLoggedIn = Client.SESSION['loggedin'];
local Form = [[
<input type="text" name="username" placeholder="username"><br>
<input type="password" name="password" placeholder="password"><br>
<input type="submit" name="login" value="login" >]]

if (IsLoggedIn) then
	Form = '<input type="submit" name="logout" value="logout">'
end

?>
<!DOCTYPE html>
<html>
<head>
<title>Test</title>
</head>

<body>
	<?lua
do -- Do - end isn't needed, but it makes it easier to notice where small bits of lua code are.
	Link:Send(Message) 
end
	?>
	<form method="POST">
<?lua
do -- Do - end isn't needed, but it makes it easier to notice where small bits of lua code are.
	Link:Send(Form)
	T)
end
?>
	</form>
</body>
</html>