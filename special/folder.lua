<?lua
local Client, Link = ...

local RequestPath = Client.RequestPath
local FullPath    = Client.FullPath

local FolderContent = cFile:GetFolderContents(FullPath)
table.remove(FolderContent, 1) -- Remove "."
table.remove(FolderContent, 1) -- Remove ".."

local Row = "<tr><td>[%s]</td><td>%s</td><td>%s</td></tr>\n"
local Content = Row:format("PARENTDIR", '<a href="..">Parent Directory</a>', "-")

for I, Path in ipairs(FolderContent) do
	local FullPath = FullPath .. "/" .. Path
	
	local Type = cFile:IsFolder(FullPath) and "DIR" or "FILE"
	local File = '<a href="' .. RequestPath .. "/" ..  Path .. '">' .. Path .. '</a>'
	local Size = cFile:GetSize(FullPath)
	Size = Size == 0 and "-" or Size
	Content = Content .. Row:format(Type, File, Size)
end

?>
<!DOCTYPE html>
<html>
<head>
	<title>Index of <?lua Link:Send(RequestPath) ?></title>
</head>

<body>
	<div>
		<h1>Index of <?lua Link:Send(RequestPath) ?></h1>
		<hr>
		<table>
			<tr><th>Type</th><th>Name</th><th>Size</th>
			<?lua Link:Send(Content) ?>
		</table>
		<hr>
		<address>MC-Web-Server</address>
	</div>
</body>
</html>