--[[-------------------------
      GENERAL SETTINGS

General configuration options.
--------------------------]]--
SGRF.Config = {} -- DO NOT TOUCH ME

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
SGRF.Rewards = {} -- DO NOT TOUCH ME

-- Add your custom rewards here!
-- NOTE: The PData variable SGRF_InSteamGroup may be used to grant external rewards (PAC3 access, etc).
-- Rewards that cannot be covered by callbacks like these should use Player:GetPData('SGRF_InSteamGroup', 'false') == 'true'
-- to determine if a user is in the Steam group or not.

-- TO ADD NEW REWARDS, use the template below.
--[===[
SGRF.Rewards.Name = {
	OneTime  = true,
	Callback = function(ply)

	end,
}
]===]--
