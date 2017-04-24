if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('sgrf/init.lua')
	
	util.AddNetworkString('SGRF_OpenSteamGroup')
	util.AddNetworkString('SGRF_ColoredChatPrint')

	local function AddCSLuaFiles(dir)
		local files, folders = file.Find(dir .. "*", "LUA")

		for _, file in pairs(files) do
			AddCSLuaFile(dir .. file)
		end

		for _, folder in pairs(folders) do
			AddCSLuaFiles(dir .. folder .. "/")
		end
	end

	AddCSLuaFiles('sgrf/client/')
end

include('sgrf/init.lua')
