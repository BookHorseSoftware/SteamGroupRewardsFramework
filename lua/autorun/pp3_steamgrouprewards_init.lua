if SERVER then
	AddCSLuaFile()
	util.AddNetworkString('PP3SGR_OpenSteamGroup')
	util.AddNetworkString('PP3SGR_ColoredChatPrint')

	local function AddCSLuaFiles(dir)
		local files, dirs = file.Find(dir .. '/*', 'LUA')

		for _, dir in pairs(dirs) do
			AddCSLuaFiles(dir)
		end

		for _, file in pairs(files) do
			AddCSLuaFile(file)
		end
	end

	AddCSLuaFiles('pp3gsr/client')

	PP3SGR = {}
	include('pp3sgr/config.lua')
	include('pp3sgr/server/sv_functions.lua')
	include('pp3sgr/server/sv_hooks.lua')
	
	PP3SGR.Log('DEBUG', 'PP3SGR LOADED SUCCESSFULLY!')
end

if CLIENT then
	include('pp3sgr/client/cl_netmessages.lua')
end