# PP3 SteamGroupRewards

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> A super-simple framework for granting users rewards for joining your Steam gruop.

SteamGroupRewards is a dead-simple, FOSS framework for granting users on your Garry's Mod server rewards for joining your Steam group. It allows for recurring or one-time rewards, and is as simple as writing callback functions. It couldn't get easier and more powerful.

## Table of Contents

- [Install](#install)
- [Configuration](#configuration)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)

## Install

Simply clone a version of this addon to your server's addon directory. There are no external dependencies.

**NOTE:** On Linux hosts, Garry's Mod does not take into account capital letters in file paths. You will likely need to _rename_ the folder you cloned to all lowercase to avoid this.

## Configuration

General configuration may be found under the **GENERAL SETTINGS** header in `lua/pp3sgr/config.lua`. The configuration options are documented below:

- `PP3SGR.Config.Commands`
  An array of possible chat commands to open the Steam group page. Note that these chat commands **also** check to see if the user has joined the Steam group upon re-entering the game, so it is best to remove any Steam group commands from other addons if possible. Set to an empty array to disable the command.
- `PP3SGR.Config.SteamGroup`
  The group ID or custom group URL end to check for player membership. This is the end of the URL for your group page, typically the custom URL you set when creating your group. It's the XXXXXX part in http://steamcommunity.com/groups/XXXXXX, or the numbers (YYYYYY) in http://steamcommunity.com/gid/YYYYYY.
- `PP3SGR.Config.APIURL`
  The URL serving the provided steamgroupmembercheck.php file. **Leave this on its default setting if you don't know what you're doing!**

## Usage

To add new rewards, edit `lua/pp3sgr/config.lua`. Under the **REWARDS SETTINGS** header, and under `PP3SGR.Rewards = {}`, add your custom rewards. Use the following format:

```lua
PP3SGR.Rewards.Name = {
	OneTime  = false,
	Callback = function(ply)
		-- Your code goes here!
	end,
}
```

**Structure:** (all elements are **required**)
- `Name`  
  The name to give this reward. Used internally in logging messages, but is still required. To use characters not supported by Lua's `.` syntax, replace the period with square brackets `[]` and add your name between quotes (`''` or `""`) inside them.
- `OneTime`  
  Designates whether or not this reward is only redeemable once (ie, if the user leaves and rejoins the group, they will not receive this reward again). Set this to `true` to enable this feature, or leave it as `false` to grant the reward every time they join.
- `Callback`  
  The callback to run to handle this reward. Takes `ply` as a parameter, which is the player currently being rewarded.

This addon also makes use of PData. To grant rewards outside of those available in callbacks, _ie_ PAC3 access or hook-related rewards, you may use the PData variable `PP3SGR_InSteamGruop`. **NOTE**, however, that `Player:GetPData` (annoyingly) returns `string`s, so you will have to check if the returned value equals the **STRING** `'true'` if the player is in the group or the **STRING** `'false'` if the player is **not** in the group.

## Maintainers

- The [PonyPwnage 3.0](https://github.com/PonyPwnage3) development team
  - [BytewaveMLP](https://github.com/BytewaveMLP)
  - [AdamRinden](https://github.com/AdamRinden)

## Contribute

For issues and feature suggestions, use our [GitHub issues page](https://github.com/PonyPwnage3/SteamGroupRewards/issues). Verify that your bug report or suggested feature has not been submitted before first! When submitting a bug report, **please** be **as detailed as possible**. Provide any Lua errors you receive, and any information we request if necessary. Also, please be patient - the development team has personal lives, too! <3

To view all upcoming features and bugfixes, as well as past changes, see our [Trello](https://trello.com/b/tIDu8ShH/steam-group-rewards).

## License

Copyright (c) PonyPwnage 3.0, 2017. Licensed under the [GNU General Public License v3.0](COPYING.md).