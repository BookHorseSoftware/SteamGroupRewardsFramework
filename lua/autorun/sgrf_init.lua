if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('sgrf/init.lua')

	util.AddNetworkString('SGRF_OpenSteamGroup')
	util.AddNetworkString('SGRF_ColoredChatPrint')

	local function AddCSLuaFiles(dir)
		local files, folders = file.Find(dir .. '*', 'LUA')

		for _, luafile in pairs(files) do
			AddCSLuaFile(dir .. luafile)
		end

		for _, luadir in pairs(folders) do
			AddCSLuaFiles(dir .. luadir .. '/')
		end
	end

	AddCSLuaFiles('sgrf/client/')
end

include('sgrf/init.lua')
