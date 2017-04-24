if SERVER then
	SGRF = SGRF or {}
	SGRF.Lib = SGRF.Lib or {}
	SGRF.Lib.SLAXML = SGRF.Lib.SLAXML or include('server/lib/slaxml.lua')

	include('config.lua')
	include('server/sv_functions.lua')
	include('server/sv_hooks.lua')

	SGRF.Log('DEBUG', 'SteamGruopRewardsFramework loaded successfully!')
end

if CLIENT then
	include('client/cl_netmessages.lua')
end
