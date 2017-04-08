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