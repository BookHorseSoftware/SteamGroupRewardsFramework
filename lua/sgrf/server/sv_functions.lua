--- Checks the given player's Steam group status with PData.
-- Does not poll any external APIs, just checks the data we've already pulled.
-- Helper function to work around PData's annoying use of strings.
-- @param ply The player to check
function SGRF.IsPlayerInGroup(ply)
	return ply:GetPData('SGRF_InSteamGroup', 'false') == 'true'
end

--- Checks if the given player has exhausted the given one-time reward.
-- @param ply    The player to check
-- @param reward The name of the reward to look for
function SGRF.HasPlayerExhaustedReward(ply, reward)
	return ply:GetPData('SGRF_ExhaustedOneTimeReward_' .. reward, 'false') == 'true'
end

--- Checks the given player for Steam group status and rewards them accordingly.
-- Checks to make sure the player has joined or left the Steam group, and grants all appropriate rewards.
-- Will also grant any one-time rewards added *after* the player joined the Steam group should they not
-- have them. Does not repeat rewards. If a one-time reward has already been granted, this function will
-- skip it. If it's a recurring reward for users that leave/join a group, they will only be granted the
-- reward if their group status changes from LEFT to JOINED.
-- @param ply                   The player to reward
-- @param skipRecurringRewards  Whether or not to skip rewards marked as Recurring; typically, these should only be granted on PlayerInitialSpawn, and avoided in situations like the Steam group command idle check hook
function SGRF.RewardPlayer(ply, skipRecurringRewards)
	SGRF.CheckPlayer(ply, function(ply)
		if not ply.InGroup then return end

		SGRF.Log('DEBUG', 'ply.InGroup = true - continuing with rewards...')

		for name, data in pairs(SGRF.Rewards) do
			if data.OneTime then
				if data.Recurring then
					SGRF.Log('ERROR', 'Reward %s is both Recurring and OneTime. It can only be one or the other. Skipping...')
					continue
				end

				if SGRF.HasPlayerExhaustedReward(ply, name) then continue end
				ply:SetPData('SGRF_ExhaustedOneTimeReward_' .. name, 'true')
			else
				if not data.Recurring or skipRecurringRewards then
					if SGRF.IsPlayerInGroup(ply) then continue end
				end
			end

			SGRF.Log('DEBUG', 'Granting reward %s to player %s', name, ply:Nick())
			data.Callback(ply)
		end

		if not SGRF.IsPlayerInGroup(ply) then
			ply:SetPData('SGRF_InSteamGroup', 'true')
			SGRF.ColoredChatPrint(ply, 'Thank you for joining our Steam group!')

			SGRF.ColoredChatBroadcast(ply, Color(255, 255, 255), ' just got rewards for joining our ', Color(100, 255, 100), 'Steam group', Color(255, 255, 255), '!')
			if SGRF.Config.Commands[1] then
				SGRF.ColoredChatBroadcast('Type ', Color(100, 100, 255), SGRF.Config.Commands[1], Color(255, 255, 255), ' in chat to join as well!')
			end
		end
	end)
end

local function recursiveXMLFallback(ply, xmlUrl, callback)
	http.Fetch(xmlUrl,
		function(xml, _, _, _)
			ply.InGroup = false
			local nextPageLink
			local traversedMembers = false

			doc = SGRF.Lib.SLAXML:dom(body)

			-- This is nasty, yes. But it works!
			SGRF.Log('DEBUG', 'Beginning body traversal...')
			for k, child in pairs(doc.kids) do
				SGRF.Log('DEBUG', '%d: %s (%s) encountered', k, child.name, child.type)
				if child.type == 'element' and child.name == 'memberList' then -- root element
					SGRF.Log('DEBUG', 'Found root element')
					for k2, child2 in pairs(child.el) do
						SGRF.Log('DEBUG', '%d - %d: %s (%s) encountered', k, k2, child2.name, child2.type) -- shut up about my code pyramids glualint :(
						if child.name == 'nextPageLink' then
							SGRF.Log('DEBUG', 'Found next page link')
							nextPageLink = child.kids[0].value
							if traversedMembers then break end -- prevent one from overstepping the other
						elseif child2.name == 'members' then -- members list
							SGRF.Log('DEBUG', 'Found members element')
							traversedMembers = true
							for k3, member in pairs(child2.el) do
								SGRF.Log('DEBUG', '%d - %d - %d: %s (%s) encountered', k, k2, k3, member.name, member.type)
								if member.name == 'steamID64' then
									SGRF.Log('DEBUG', 'Found steamID64 element with value %s', el.value)

									if el.value == steamid64 then
										SGRF.Log('DEBUG', 'Found matching steamID64 element')
										ply.InGroup = true
										break
									end
								end
							end
							if nextPageLink then break end -- prevent one from overstepping the other
						end
					end
					break
				end
			end

			if ply.InGroup then
				SGRF.Log('DEBUG', 'Player %s (%s) is in group (XML API).', ply:Nick(), ply:SteamID())

				if not SGRF.IsPlayerInGroup(ply) then
					SGRF.Log('DEBUG', 'Player %s (%s) group status changed (JOINED)!', ply:Nick(), ply:SteamID())
				end

				callback(ply)
			elseif nextPageLink then
				SGRF.Log('DEBUG', 'Player %s (%s) not found on page "%s"', ply:Nick(), ply:SteamID(), xmlUrl)
				recursiveXMLFallback(ply, nextPageLink, callback)
			else
				SGRF.Log('DEBUG', 'Player %s (%s) is not in group (XML API).', ply:Nick(), ply:SteamID())

				if SGRF.IsPlayerInGroup(ply) then
					SGRF.Log('DEBUG', 'Player %s (%s) group status changed (LEFT)!', ply:Nick(), ply:SteamID())
					ply:SetPData('SGRF_InSteamGroup', 'false')
				end

				callback(ply)
			end
		end,
		function(error)
			SGRF.Log('ERROR', 'Fallback API check failed with code %s', error)
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
	local url = 'https://api.steampowered.com/ISteamUser/GetUserGroupList/v1/?format=json&key=' .. SGRF.Config.SteamAPIKey .. '&steamid=' .. steamid64

	http.Fetch(url,
		function(body, _, _, _)
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

					if not SGRF.IsPlayerInGroup(ply) then
						SGRF.Log('DEBUG', 'Player %s (%s) group status changed (JOINED)!', ply:Nick(), ply:SteamID())
					end
				else
					SGRF.Log('DEBUG', 'Player %s (%s) is not in group.', ply:Nick(), ply:SteamID())

					if SGRF.IsPlayerInGroup(ply) then
						SGRF.Log('DEBUG', 'Player %s (%s) group status changed (LEFT)!', ply:Nick(), ply:SteamID())
						ply:SetPData('SGRF_InSteamGroup', 'false')
					end
				end

				callback(ply)
			else
				SGRF.Log('DEBUG', 'Steam API check failed for player %s (%s) - attempting fallback XML method...', ply:Nick(), ply:SteamID())

				local xmlUrl = 'http://steamcommunity.com/gid/' .. SGRF.Config.SteamGroup .. '/memberslistxml/?xml=1'

				recursiveXMLFallback(ply, xmlUrl, callback)
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
	if (channel == 'DEBUG' or channel == 'TRACE') and not SGRF.Config.LogDebugMessages then return end

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
