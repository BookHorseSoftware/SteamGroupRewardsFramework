# SteamGroupRewardsFramework

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme) [![Build Status](https://travis-ci.org/BookHorseSoftware/SteamGroupRewardsFramework.svg?branch=master)](https://travis-ci.org/BookHorseSoftware/SteamGroupRewardsFramework)

> A super-simple framework for granting users rewards for joining your Steam group.

SteamGroupRewardsFramework is a dead-simple, FOSS framework for granting users on your Garry's Mod server rewards for joining your Steam group. It allows for recurring or one-time rewards, and is as simple as writing callback functions. It couldn't get easier and more powerful.

## Table of Contents

- [Install](#install)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Adding new rewards](#adding-new-rewards)
  - [Rewards outside of callbacks](#rewards-outside-of-callbacks)
    - [Example: PAC3 restriction](#example-pac3-restriction)
- [API](#api)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)

## Install

Simply clone a version of this addon to your server's addon directory. There are no external dependencies.

**NOTE:** On Linux hosts, Garry's Mod does not take into account capital letters in file paths. You will likely need to _rename_ the folder you cloned to all lowercase to avoid this.

## Configuration

General configuration may be found under the **GENERAL SETTINGS** header in `lua/sgrf/config.lua`. The configuration options are documented below:

- `SGRF.Config.Commands`

  An array of possible chat commands to open the Steam group page. Note that these chat commands **also** check to see if the user has joined the Steam group upon re-entering the game, so it is best to remove any Steam group commands from other addons if possible. Set to an empty array to disable the command.

- `SGRF.Config.SteamGroup`

  The group ID to check for player membership. It's the numbers (YYYYYY) in http://steamcommunity.com/gid/YYYYYY. This number can also be found in your group's "edit profile" section.

- `SGRF.Config.SteamAPIKey`

  This is a Steam Community API key. You can find it at http://steamcommunity.com/dev/apikey.

- `SGRF.Config.LogDebugMessages`

  Logs debug and trace output for debugging purposes. Only set this if you know what you're doing, since these messages can get pretty spammy.

- `SGRF.Config.SilentMode`

  Controls whether broadcast chat messages should be sent to players.

## Usage

### Adding new rewards

To add new rewards, edit `lua/sgrf/config.lua`. Under the **REWARDS SETTINGS** header, and under `SGRF.Rewards = {}`, add your custom rewards. Use the following format:

```lua
SGRF.Rewards.Name = {
    OneTime   = false,
    Recurring = false,
    Callback  = function(ply)
        -- Your code goes here!
    end,
}
```

**Structure:** (all elements are **required**)

- `Name`

  The name to give this reward. Used internally in logging messages, but is still required. To use characters not supported by Lua's `.` syntax, replace the period with square brackets `[]` and add your name between quotes (`''` or `""`) inside them.

- `OneTime`

  Designates whether or not this reward is only redeemable once (ie, if the user leaves and rejoins the group, they will not receive this reward again). Set this to `true` to enable this feature, or leave it as `false` to grant the reward every time they join.

- `Recurring`

  Designates whether or not this reward is redeemable every time the user connects to the server, instead of only the first time the addon checks. Typically, rewards will only be granted when the user connects to the server for the first time after joining the Steam group, or if they join the Steam group through the in-game chat command for SGRF. Set this to `true` to enable this feature, or leave it as `false` to only grant the user the reward on the **first check** after the user joins.

  **NOTE:** Setting both `OneTime` and `Recurring` is **invalid** and will cause SGRF to skip the reward until the invalid state is fixed.

- `Callback`

  The callback to run to handle this reward. Takes `ply` as a parameter, which is the player currently being rewarded.

### Rewards outside of callbacks

This addon also makes use of PData. To grant rewards outside of those available in callbacks, _eg_ PAC3 access or hook-related rewards, use the helper function `SGRF.IsPlayerInGroup(ply)` documented in [API](#api).

Alternatively, you may use the PData variable `SGRF_InSteamGroup`. **NOTE**, however, that `Player:GetPData` (annoyingly) returns `string`s, so you will have to check if the returned value equals the **STRING** `'true'` if the player is in the group or the **STRING** `'false'` if the player is **not** in the group.

#### Example: PAC3 restriction

Modify the following script to fit your needs, and place it somewhere in `lua/autorun/server/`. This will prevent users from accessing the PAC editor and loading their outfits until they've joined the Steam group.

```lua
local function restrictPAC3(ply)
    if not SGRF.IsPlayerInGroup(ply) then
        return false, "You must join the Steam group before you can use PAC3! (see !sg)"
    end
end
hook.Add('PrePACConfigApply', 'SGRF - PAC3 Restriction', restrictPAC3)
hook.Add('PrePACEditorOpen', 'SGRF - PAC3 Restriction', restrictPAC3)
```

## API

### Global functions

- `SGRF.RewardPlayer(ply)` - **SERVERSIDE**

  Manually rechecks a player and rewards them accordingly. This is called on spawn, or when a player returns from using the configured Steam group commands.

  - `ply` - The player to check and reward (if applicable)

- `SGRF.CheckPlayer(ply, callback)` - **SERVERSIDE**

  Manually rechecks a player's group membership status. The bulk of the processing goes on here.

  We recommend using the PData variable mentioned in [Rewards outside of callbacks](#rewards-outside-of-callbacks) if you want to implement your own rewards that can't be handled by callbacks. However, if you find a use for this function, go right ahead and use it.

  - `ply` - The player to check
  - `callback` - The callback to run once operations are complete
    - `ply` - The player object from earlier, for convenience

- `SGRF.IsPlayerInGroup(ply)` - **SERVERSIDE**

  Checks the given player's Steam group status with PData.

  Does not poll any external APIs, just checks the data we've already pulled. Helper function to work around PData's annoying use of strings.

  - `ply` - The player to check

- `SGRF.HasPlayerExhaustedReward(ply, reward)` - **SERVERSIDE**

  Checks if the given player has exhausted the given one-time reward.

  - `ply` - The player to check
  - `reward` - The name of the reward to look for

- `SGRF.Log(channel, _str, ...)` - **SERVERSIDE**

  Writes a log message to the server console prefixed with the given channel. Uses `string.format` internally.

  - `channel` - The channel to write to
  - `_str` - The string to write (may use `string.format`-style format strings)
  - `...` - Additional arguments for `string.format`

- `SGRF.ColoredChatPrint(ply, ...)` - **SERVERSIDE**

  Writes a prefixed, colored chat message to a given player's chat. Uses `chat.AddText` internally.

  - `ply` - The player to write the chat message to
  - `...` - A set of `Color`s and `string`s to pass to `chat.AddText`

- `SGRF.ColoredChatBroadcast(...)` - **SERVERSIDE**

  Writes a prefixed, colored chat message to every player on the server's chat. Uses `chat.AddText` internally.

  - `...` - A set of `Color`s and `string`s to pass to `chat.AddText`

## Maintainers

- [Book Horse Software](https://github.com/BookHorseSoftware)
  - [BytewaveMLP](https://github.com/BytewaveMLP)
  - [antigravities](https://alexandra.moe/)

## Contribute

For issues and feature suggestions, use our [GitHub issues page](https://github.com/BookHorseSoftware/SteamGroupRewardsFramework/issues). Verify that your bug report or suggested feature has not been submitted before first! When submitting a bug report, **please** be **as detailed as possible**. Provide any Lua errors you receive, and any information we request if necessary. Also, please be patient - the development team has personal lives, too! <3

To view all upcoming features and bugfixes, as well as past changes, see our [Trello](https://trello.com/b/tIDu8ShH/steam-group-rewards).

## License

Copyright (c) Book Horse Software, 2017. Licensed under the [GNU General Public License v3.0](LICENSE).
