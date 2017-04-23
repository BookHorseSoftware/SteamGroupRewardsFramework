--- Checks the given player for Steam group status and rewards them accordingly.
-- Checks to make sure the player has joined or left the Steam group, and grants all appropriate rewards.
-- Will also grant any one-time rewards added *after* the player joined the Steam group should they not
-- have them. Does not repeat rewards. If a one-time reward has already been granted, this function will
-- skip it. If it's a recurring reward for users that leave/join a group, they will only be granted the
-- reward if their group status changes from LEFT to JOINED.
-- @param ply  The player to reward
function SGRF.RewardPlayer(ply)
	SGRF.CheckPlayer(ply, function(ply)
		if not ply.InGroup then return end

		SGRF.Log('DEBUG', 'ply.InGroup = true - continuing with rewards...')

		for name, data in pairs(SGRF.Rewards) do
			if data.OneTime then
				if ply:GetPData('SGRF_ExhaustedOneTimeReward_' .. name, 'false') == 'true' then continue end
				ply:SetPData('SGRF_ExhaustedOneTimeReward_' .. name, 'true')
			else
				if ply:GetPData('SGRF_InSteamGroup', 'false') == 'true' then continue end
			end

			SGRF.Log('DEBUG', 'Granting reward %s to player %s', name, ply:Nick())
			data.Callback(ply)
		end

		if ply:GetPData('SGRF_InSteamGroup', 'false') == 'false' then
			ply:SetPData('SGRF_InSteamGroup', 'true')
			SGRF.ColoredChatPrint(ply, 'Thank you for joining our Steam group!')

			SGRF.ColoredChatBroadcast(ply, Color(255, 255, 255), ' just got rewards for joining our ', Color(100, 255, 100), 'Steam group', Color(255, 255, 255), '!')
			if SGRF.Config.Commands[1] then
				SGRF.ColoredChatBroadcast('Type ', Color(100, 100, 255), SGRF.Config.Commands[1], Color(255, 255, 255), ' in chat to join as well!')
			end
		end
	end)
end

--- Checks to see if the user has joined the configured Steam group.
-- Hits the configured API URL to verify that the given user has joined the Steam group. Runs the given
-- callback when completed. The Player instance will have an InGroup variable designating whether or not
-- the user associated with it has joined the Steam group or not, and will have the PData value
-- 'SGRF_InSteamGroup' set to 'true' if they're a member of the group, or 'false' if they've left.
-- @param ply       The player to check
-- @param callback  The callback to run when complete
function SGRF.CheckPlayer(ply, callback)
	local steamid64 = ply:SteamID64()
	local url = 'https://api.steampowered.com/ISteamUser/GetUserGroupList/v1/?format=json&key=' .. SGRF.Config.SteamAPIKey .. "&steamid=" .. steamid64

	http.Fetch(url,
		function(body, len, headers, code)
			SGRF.Log('TRACE', body)
			data = util.JSONToTable(body)
			if data and data.response.success == true then
				ply.InGroup = false
				
				for k, v in pairs(data.response.groups) do
					if v.gid == SGRF.Config.SteamGroup then
						ply.InGroup = true
						break
					end
				end

				if ply.InGroup then
					SGRF.Log('DEBUG', 'Player %s (%s) is in group.', ply:Nick(), ply:SteamID())

					if ply:GetPData('SGRF_InSteamGroup', 'false') == 'false' then
						SGRF.Log('DEBUG', 'Player %s (%s) group status changed (JOINED)!', ply:Nick(), ply:SteamID())
					end
				else
					SGRF.Log('DEBUG', 'Player %s (%s) is not in group.', ply:Nick(), ply:SteamID())

					if ply:GetPData('SGRF_InSteamGroup', 'false') == 'true' then
						SGRF.Log('DEBUG', 'Player %s (%s) group status changed (LEFT)!', ply:Nick(), ply:SteamID())
						ply:SetPData('SGRF_InSteamGroup', 'false')
					end
				end

				callback(ply)
			else
				SGRF.Log('DEBUG', 'Steam API check failed for player %s (%s) - attempting fallback XML method...', ply:Nick(), ply:SteamID())

				local url = 'http://steamcommunity.com/gid/' .. SGRF.Config.SteamGroup .. '/memberslistxml/?xml=1'

				http.Fetch(url,
					function(body, len, headers, code)
						ply.InGroup = false

						parser = SGRF.Lib.SLAXML:parser{
							text = function(text)
								if tonumber(text) and tonumber(text) == steamid64 then
									SGRF.Log('INFO', 'Player %s (%s) is in group according to XML API', ply:Nick(), ply:SteamID())
									ply.InGroup = true
								end
							end
						}

						parser:parse(body, {stripWhitespace = true})

						if ply.InGroup then
							SGRF.Log('DEBUG', 'Player %s (%s) is in group (XML APOI).', ply:Nick(), ply:SteamID())

							if ply:GetPData('SGRF_InSteamGroup', 'false') == 'false' then
								SGRF.Log('DEBUG', 'Player %s (%s) group status changed (JOINED)!', ply:Nick(), ply:SteamID())
							end
						else
							SGRF.Log('DEBUG', 'Player %s (%s) is not in group (XML API).', ply:Nick(), ply:SteamID())

							if ply:GetPData('SGRF_InSteamGroup', 'false') == 'true' then
								SGRF.Log('DEBUG', 'Player %s (%s) group status changed (LEFT)!', ply:Nick(), ply:SteamID())
								ply:SetPData('SGRF_InSteamGroup', 'false')
							end
						end

						callback(ply)
					end,
					function(error)
						SGRF.Log('ERROR', 'Fallback API check failed with code %s', error)
					end)
			end
		end,
		function(error)
			SGRF.Log('ERROR', 'API check failed with code %s', error)
		end)
end

--- Writes a formatted message to stdout
-- @param      channel  The channel to echo to
-- @param      _str     The string to write to the log
-- @param[opt] ...      Anything to pass to string.format
function SGRF.Log(channel, _str, ...)
	local str = _str
	if ... then
		if type(...) == 'table' then
			str = string.format(_str, unpack(...))
		else
			str = string.format(_str, ...)
		end
	end

	print(string.format('[SGRF]: %s: %s', channel, str))
end

--- Writes a colored string to the given player's chat
-- Workaround for Garry's Mod not having this function serverside - basically a serverside
-- wrapper around chat.AddText.
-- @param           ply     The player to send a chat message to
-- @param[opt]      color   The color to use
-- @param           str     The string to write using the given color
-- @param[opt]      color2  The color to use
-- @param[optchain] str2    The string to write using the given color
function SGRF.ColoredChatPrint(ply, ...)
	local args = {Color(255, 255, 255), '[', Color(157, 12, 207), 'SGRF', Color(255, 255, 255), ']: ', ...}

	net.Start('SGRF_ColoredChatPrint')
		net.WriteTable(args)
	net.Send(ply)
end

--- Writes a colored string to everyone's chats
-- Workaround for Garry's Mod not having this function serverside - basically a serverside
-- wrapper around chat.AddText.
-- @param[opt]      color   The color to use
-- @param           str     The string to write using the given color
-- @param[opt]      color2  The color to use
-- @param[optchain] str2    The string to write using the given color
function SGRF.ColoredChatBroadcast(...)
	local args = {Color(255, 255, 255), '[', Color(157, 12, 207), 'SGRF', Color(255, 255, 255), ']: ', ...}

	net.Start('SGRF_ColoredChatPrint')
		net.WriteTable(args)
	net.Broadcast()
end

