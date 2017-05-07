--[[-------------------------
      GENERAL SETTINGS

General configuration options.
--------------------------]]--
SGRF.Config = SGRF.Config or {} -- DO NOT TOUCH ME

--- Commands to open the Steam group page
-- These commands may be used in chat to open the Steam group page for the group designated
-- below. The addon will check if a player has joined the group upon re-entering the game, and
-- will reward them accordingly.
SGRF.Config.Commands = {
	'!steamgroup',
	'/steamgroup',
	'!sg',
	'/sg',
}

--- The group ID to check
-- This is your group's ID. You can find this on your group's profile edit page, after the "ID:"
-- label.
SGRF.Config.SteamGroup = 'CHANGE ME'

--- Your Steam Web API key
-- You can get this at https://steamcommunity.com/dev/apikey.
SGRF.Config.SteamAPIKey = 'CHANGE ME'

--[[-------------------------
       REWARDS SETTINGS

Add your custom rewards here!
-------------------------]]--
SGRF.Rewards = SGRF.Rewards or {} -- DO NOT TOUCH ME

-- Add your custom rewards here!
-- To grant rewards outside of those available in callbacks, eg PAC3 access or hook-related rewards,
-- use the helper function SGRF.IsPlayerInGroup(ply) documented below.
-- Alternatively, you may use the PData variable SGRF_InSteamGroup. NOTE, however, that Player:GetPData
-- (annoyingly) returns strings, so you will have to check if the returned value equals the STRING 'true'
-- if the player is in the group or the STRING 'false' if the player is not in the group.

-- TO ADD NEW REWARDS, use the template below.
--[===[
SGRF.Rewards.Name = {
	OneTime  = true,
	Callback = function(ply)

	end,
}
]===]--
