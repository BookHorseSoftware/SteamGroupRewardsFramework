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
-- This is the end of the URL for your group page, typically the custom URL you set when creating
-- your group. It's the XXXXXX part in http://steamcommunity.com/groups/XXXXXX, or the numbers (YYYYYY)
-- in http://steamcommunity.com/gid/YYYYYY.
SGRF.Config.SteamGroup = 'CHANGE ME'

--- The URL serving the provided steamgroupmembercheck.php file
-- Leave this on its default setting if you don't know what you're doing.
SGRF.Config.APIURL = 'https://bytewave.antigravities.net/steamgroup.php'

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
