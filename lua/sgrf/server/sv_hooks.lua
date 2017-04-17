local function steamGroupCommand(ply, text, team)
	for _, cmd in ipairs(SGRF.Config.Commands) do
		if text == cmd then
			net.Start('SGRF_OpenSteamGroup')
				net.WriteString(SGRF.Config.SteamGroup)
			net.Send(ply)

			ply.inSteamGroupUI = true

			return ''
		end
	end
end
hook.Add('PlayerSay', 'SGRF - Steam Group Command', steamGroupCommand)

local function checkIfJoinedGroup(ply)
	if ply.inSteamGroupUI then
		SGRF.RewardPlayer(ply)

		ply.inSteamGroupUI = false
	end
end
hook.Add('KeyPress', 'SGRF - Steam Group Check', checkIfJoinedGroup)

hook.Add('PlayerInitialSpawn', 'SGRF - Steam Group Spawn Check', SGRF.RewardPlayer)