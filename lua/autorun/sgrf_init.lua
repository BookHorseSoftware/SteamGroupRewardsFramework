if SERVER then
	AddCSLuaFile()
	util.AddNetworkString('SGRF_OpenSteamGroup')
	util.AddNetworkString('SGRF_ColoredChatPrint')

	local function AddCSLuaFiles(dir)
		local files, dirs = file.Find(dir .. '/*', 'LUA')

		for _, dir in pairs(dirs) do
			AddCSLuaFiles(dir)
		end

		for _, file in pairs(files) do
			AddCSLuaFile(file)
		end
	end

	AddCSLuaFiles('sgrf/client')

	SGRF = {}
	include('sgrf/config.lua')
	include('sgrf/server/sv_functions.lua')
	include('sgrf/server/sv_hooks.lua')
	
	SGRF.Log('DEBUG', 'SteamGruopRewardsFramework loaded successfully!')
end

if CLIENT then
	include('SGRF/client/cl_netmessages.lua')
end