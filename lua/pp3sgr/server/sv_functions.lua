--- Checks the given player for Steam group status and rewards them accordingly.
-- Checks to make sure the player has joined or left the Steam group, and grants all appropriate rewards.
-- Will also grant any one-time rewards added *after* the player joined the Steam group should they not
-- have them. Does not repeat rewards. If a one-time reward has already been granted, this function will
-- skip it. If it's a recurring reward for users that leave/join a group, they will only be granted the
-- reward if their group status changes from LEFT to JOINED.
-- @param ply  The player to reward
function PP3SGR.RewardPlayer(ply)
	PP3SGR.CheckPlayer(ply, function(ply)
		if not ply.InGroup then return end

		for name, data in pairs(PP3SGR.Rewards) do
			if data.OneTime then
				if ply:GetPData('PP3SGR_ExhaustedOneTimeReward_' .. name, 'false') == 'true' then continue end
				ply:SetPData('PP3SGR_ExhaustedOneTimeReward_' .. name, 'true')
			else
				if ply:GetPData('PP3SGR_InSteamGroup', 'false') == 'true' then continue end
			end

			PP3SGR.Log('DEBUG', 'Granting reward %s to player %s', name, ply:Nick())
			data.Callback(ply)
		end
	end)
end

--- Checks to see if the user has joined the configured Steam group.
-- Hits the configured API URL to verify that the given user has joined the Steam group. Runs the given
-- callback when completed. The Player instance will have an InGroup variable designating whether or not
-- the user associated with it has joined the Steam group or not, and will have the PData value
-- 'PP3SGR_InSteamGroup' set to 'true' if they're a member of the group, or 'false' if they've left.
-- @param ply       The player to check
-- @param callback  The callback to run when complete
function PP3SGR.CheckPlayer(ply, callback)
	local url = PP3SGR.Config.APIURL .. '?group=' .. PP3SGR.Config.SteamGroup .. '&steamid=' .. ply:SteamID64()

	http.Fetch(url,
		function(body, len, headers, code)
			PP3SGR.Log('TRACE', body)
			data = util.JSONToTable(body)
			if data.status == 'success' then
				if data.inGroup then
					PP3SGR.Log('DEBUG', 'Player %s (%s) is in group.', ply:Nick(), ply:SteamID())
					ply.InGroup = true

					if ply:GetPData('PP3SGR_InSteamGroup', 'false') == 'false' then
						PP3SGR.Log('DEBUG', 'Player %s (%s) group status changed (JOINED)!', ply:Nick(), ply:SteamID())
						ply:SetPData('PP3SGR_InSteamGroup', 'true')
					end
				else
					PP3SGR.Log('DEBUG', 'Player %s (%s) is not in group.', ply:Nick(), ply:SteamID())
					ply.InGroup = false

					if ply:GetPData('PP3SGR_InSteamGroup', 'false') == 'true' then
						PP3SGR.Log('DEBUG', 'Player %s (%s) group status changed (LEFT)!', ply:Nick(), ply:SteamID())
						ply:SetPData('PP3SGR_InSteamGroup', 'false')
					end
				end
			else
				PP3SGR.Log('DEBUG', 'Request failed for player %s (%s) - %s: %s (%s)', ply:Nick(), ply:SteamID(), data.status, data.message, data.comment)
			end

			callback(ply)
		end,
		function(error)
			PP3SGR.Log('ERROR', 'API check failed with code %s', error)
		end)
end

--- Writes a formatted message to stdout
-- @param      channel  The channel to echo to
-- @param      _str     The string to write to the log
-- @param[opt] ...      Anything to pass to string.format
function PP3SGR.Log(channel, _str, ...)
	local str = _str
	if ... then
		if type(...) == 'table' then
			str = string.format(_str, unpack(...))
		else
			str = string.format(_str, ...)
		end
	end

	print(string.format('[PP3SGR]: %s: %s', channel, str))
end

--- Writes a colored string to the given player's chat
-- Workaround for Garry's Mod not having this function serverside - basically a serverside
-- wrapper around chat.AddText.
-- @param           ply     The player to send a chat message to
-- @param[opt]      color   The color to use
-- @param           str     The string to write using the given color
-- @param[opt]      color2  The color to use
-- @param[optchain] str2    The string to write using the given color
function PP3SGR.ColoredChatPrint(ply, ...)
	local args = {...}

	net.Start('PP3SGR_ColoredChatPrint')
		net.WriteTable(args)
	net.Send(ply)
end