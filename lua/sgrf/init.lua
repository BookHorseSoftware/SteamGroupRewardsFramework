if SERVER then
	local function AddCSLuaFiles(dir)
		local files, folders = file.Find(dir .. '*', 'LUA')

		for _, luafile in pairs(files) do
			AddCSLuaFile(dir .. luafile)
		end

		for _, luadir in pairs(folders) do
			AddCSLuaFiles(dir .. luadir .. '/')
		end
	end

	AddCSLuaFile()
	AddCSLuaFiles('sgrf/client/')
	AddCSLuaFile('sgrf/init.lua')

	-- Network strings
	util.AddNetworkString('SGRF_OpenSteamGroup')
	util.AddNetworkString('SGRF_ColoredChatPrint')

	-- Initialize global tables / vars
	SGRF = SGRF or {}
	SGRF.Lib = SGRF.Lib or {}
	SGRF.Lib.SLAXML = SGRF.Lib.SLAXML or include('server/lib/slaxml.lua')

	-- Load other files
	include('config.lua')
	include('server/sv_functions.lua')
	include('server/sv_hooks.lua')

	-- We're done!
	SGRF.Log('DEBUG', 'SteamGruopRewardsFramework loaded successfully!')
end

if CLIENT then
	include('client/cl_netmessages.lua')
end
