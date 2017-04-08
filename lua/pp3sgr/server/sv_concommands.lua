concommand.Add('pp3sgr_check', PP3SGR.RewardPlayer)
-- concommand.Add('pp3sgr_debug_leavegroup', function(ply)
-- 	PP3SGR.Log('DEBUG', 'Resetting JOINED status...')
-- 	ply:SetPData('PP3SGR_InSteamGroup', 'false')
-- end)
-- concommand.Add('pp3sgr_debug_resetonetimerewards', function(ply)
-- 	PP3SGR.Log('DEBUG', 'Resetting one-time reward status for all rewards...')
-- 	for name, data in pairs(PP3SGR.Rewards) do
-- 		if data.OneTime then
-- 			PP3SGR.Log('DEBUG', 'Resetting one-time reward status for reward %s...', name)
-- 			ply:SetPData('PP3SGR_ExhaustedOneTimeReward_' .. name, 'false')
-- 		end
-- 	end
-- end)
-- concommand.Add('pp3sgr_debug_resetonetimereward', function(ply, cmd, args)
-- 	if not args[1] then return end

-- 	PP3SGR.Log('DEBUG', 'Resetting one-time reward status for reward %s...', args[1])
-- 	ply:SetPData('PP3SGR_ExhaustedOneTimeReward_' .. args[1], 'false')
-- end)