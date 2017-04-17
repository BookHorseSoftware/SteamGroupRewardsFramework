net.Receive('SGRF_OpenSteamGroup', function()
	gui.OpenURL('http://steamcommunity.com/groups/' .. net.ReadString())
end)

net.Receive('SGRF_ColoredChatPrint', function()
	local args = net.ReadTable()
	chat.AddText(unpack(args))
end)