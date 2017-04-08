--[[-------------------------
      GENERAL SETTINGS

General configuration options.
--------------------------]]--
PP3SGR.Config = {} -- DO NOT TOUCH ME

--- Commands to open the Steam group page
-- These commands may be used in chat to open the Steam group page for the group designated
-- below. The addon will check if a player has joined the group upon re-entering the game, and
-- will reward them accordingly.
PP3SGR.Config.Commands = {
	'!steamgroup',
	'/steamgroup',
	'!sg',
	'/sg',
}

--- The group ID to check
-- This is the end of the URL for your group page, typically the custom URL you set when creating
-- your group. It's the XXXXXX part in http://steamcommunity.com/groups/XXXXXX, or the numbers (YYYYYY)
-- in http://steamcommunity.com/gid/YYYYYY.
PP3SGR.Config.SteamGroup = 'ponypwn3'

--- The URL serving the provided steamgroupmembercheck.php file
-- Leave this on its default setting if you don't know what you're doing.
PP3SGR.Config.APIURL = 'https://bytewave.antigravities.net/steamgroup.php'

--[[-------------------------
       REWARDS SETTINGS

Add your custom rewards here!
-------------------------]]--
PP3SGR.Rewards = {} -- DO NOT TOUCH ME

-- TO ADD NEW REWARDS, use the template below.
--[===[
PP3SGR.Rewards.Name = {
	OneTime  = true,
	Callback = function(ply)

	end,
}
]===]--
