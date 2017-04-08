net.Receive('PP3SGR_OpenSteamGroup', function()
	gui.OpenURL('http://steamcommunity.com/groups/' .. net.ReadString())
end)