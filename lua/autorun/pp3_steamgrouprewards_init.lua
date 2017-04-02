if SERVER then
	AddCSLuaFile()

	local function AddCSLuaFiles(dir)
		local files, dirs = file.Find(dir .. '/*', 'LUA')

		for _, dir in pairs(dir) do
			AddCSLuaFiles(dir)
		end

		for _, file in pairs(files) do
			AddCSLuaFile(file)
		end
	end

	AddCSLuaFiles('pp3gsr/client')
	AddCSLuaFiles('pp3gsr/shared')
end

if CLIENT then

end