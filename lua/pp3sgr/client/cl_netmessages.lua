net.Receive('PP3SGR_OpenSteamGroup', function()
	gui.OpenURL('http://steamcommunity.com/groups/' .. net.ReadString())
end)

net.Receive('PP3SGR_ColoredChatPrint', function()
	local args = net.ReadTable()
	chat.AddText(unpack(args))
end)