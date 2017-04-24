if SERVER then
	SGRF = SGRF or {}
	SGRF.Lib = SGRF.Lib or {}
	SGRF.Lib.SLAXML = SGRF.Lib.SLAXML or include('lib/slaxml.lua')

	include('config.lua')
	include('sv_functions.lua')
	include('sv_hooks.lua')

	SGRF.Log('DEBUG', 'SteamGruopRewardsFramework loaded successfully!')
end

if CLIENT then
	include('cl_netmessages.lua')
end