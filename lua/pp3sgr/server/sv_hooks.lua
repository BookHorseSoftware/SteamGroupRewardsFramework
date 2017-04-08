local function steamGroupCommand(ply, text, team)
	for _, cmd in ipairs(PP3SGR.Config.Commands) do
		if text == cmd then
			net.Start('PP3SGR_OpenSteamGroup')
				net.WriteString(PP3SGR.Config.SteamGroup)
			net.Send(ply)

			ply.inSteamGroupUI = true

			return ''
		end
	end
end
hook.Add('PlayerSay', 'PP3SGR - Steam Group Command', steamGroupCommand)

local function checkIfJoinedGroup(ply)
	if ply.inSteamGroupUI then
		PP3SGR.RewardPlayer(ply)

		ply.inSteamGroupUI = false
	end
end
hook.Add('KeyPress', 'PP3SGR - Steam Group Check', checkIfJoinedGroup)

hook.Add('PlayerInitialSpawn', 'PP3SGR - Steam Group Spawn Check', PP3SGR.RewardPlayer)