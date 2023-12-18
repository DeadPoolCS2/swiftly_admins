<br/>
<p align="center">
  <a href="https://github.com/swiftly-solution/swiftly_admins">
    <img src="https://media.discordapp.net/attachments/979452783466000466/1168236894652469248/Swiftly_Logo.png?ex=6575f264&is=65637d64&hm=dd2834983bebeab98d7febd44bb3bd20e9aded13ecefac63cc990b222a9d9e9e&=&format=webp&quality=lossless&width=468&height=468" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] Admin System</h3>

  <p align="center">
    A simple plugin for Swiftly that implements an Admin System.
    <br/>
    <br/>
    <a href="https://github.com/swiftly-solution/swiftly_admins/issues">Report Bug</a>
    .
    <a href="https://github.com/swiftly-solution/swiftly_admins/issues">Request Feature</a>
  </p>
</p>

![Downloads](https://img.shields.io/github/downloads/swiftly-solution/swiftly_admins/total) ![Contributors](https://img.shields.io/github/contributors/swiftly-solution/swiftly_admins?color=dark-green) ![Issues](https://img.shields.io/github/issues/swiftly-solution/swiftly_admins) ![License](https://img.shields.io/github/license/swiftly-solution/swiftly_admins) 

### Installation 👀

1. Download the newest [release](https://github.com/swiftly-solution/swiftly_admins/releases).
2. Everything is drag & drop, so i think you can do it!
3. Setup database connection in `addons/swiftly/configs/databases.json` with the key `swiftly_admins` like in the following example:
```json
{
    "swiftly_admins": {
        "host": "...",
        "username": "...",
        "password": "...",
        "database": "...",
        "port": 3306
    }
}
```
(!) Don't forget to replace the `...` with the actual values !!

### Configuring the plugin 🧐

* After installing the plugin, you need to change the prefix from `addons/swiftly/configs/plugins` (optional) and if you want, you can change the messages from `addons/swiftly/translations`.

### Admin Flags 🛡️

* Currently supported flags are the following:

| Flag | Script Name |                             Description                             |
|:----:|:---:|:-------------------------------------------------------------------:|
|   a  | ADMFLAG_RESERVATION |                            Reserved Slot                            |
|   b  | ADMFLAG_GENERIC |                     Generic Admin; Access to u@                     |
|   c  | ADMFLAG_KICK |                             Kick players                            |
|   d  | ADMFLAG_BAN |                             Ban players                             |
|   e  | ADMFLAG_UNBAN |                            Unban players                            |
|   f  | ADMFLAG_SLAY |                                 Slay                                |
|   g  | ADMFLAG_CHANGEMAP |                              Change map                             |
|   h  | ADMFLAG_CONVARS |                         Change server cvars                         |
|   i  | ADMFLAG_CONFIG |         Executes commands over plugin specific config files         |
|   j  | ADMFLAG_CHAT |               Access to private say, center say, etc.               |
|   k  | ADMFLAG_VOTE |                       Creates a vote on server                      |
|   l  | ADMFLAG_PASSWORD |                      Changes server's password                      |
|   m  | ADMFLAG_RCON |                          Use RCON commands                          |
|   n  | ADMFLAG_CHEATS | Changes sv_cheats and allows to use cheating commands (noclip, etc) |
|   z  | ADMFLAG_ROOT |                         Access to everything                        |
|   o  | ADMFLAG_CUSTOM1 |                            Custom Flag 1                            |
|   p  | ADMFLAG_CUSTOM2 |                            Custom Flag 2                            |
|   q  | ADMFLAG_CUSTOM3 |                            Custom Flag 3                            |
|   r  | ADMFLAG_CUSTOM4 |                            Custom Flag 4                            |
|   s  | ADMFLAG_CUSTOM5 |                            Custom Flag 5                            |
|   t  | ADMFLAG_CUSTOM6 |                            Custom Flag 6                            |

### Admin Commands 💬

* Base commands provided by this plugin:

|      Command     |        Flag       |               Description              |
|:----------------:|:-----------------:|:--------------------------------------:|
|   !reloadadmins  |    ADMFLAG_ROOT   |        Reload admins on server.        |
|       !rcon      |    ADMFLAG_RCON   |      Executes a command on server.     |
|       !slay      |    ADMFLAG_SLAY   |             Kills a player.            |
|       !slap      |    ADMFLAG_SLAY   |             Slaps a player.            |
| !map / !changemap | ADMFLAG_CHANGEMAP |       Changes the map on server.       |
|       !chat      |    ADMFLAG_CHAT   |     Sends a message on admin chat.     |
|       !csay      |    ADMFLAG_CHAT   |   Sends a centered message on server.  |
|       !say       |    ADMFLAG_CHAT   |       Sends a message on server.       |
|       !psay      |    ADMFLAG_CHAT   |         Sends a private message        |
|       !mute      |    ADMFLAG_CHAT   |        Mutes a player on voice.        |
|      !unmute     |    ADMFLAG_CHAT   |       Unmutes a player on voice.       |
|       !gag       |    ADMFLAG_CHAT   |         Mutes a player on chat.        |
|      !ungag      |    ADMFLAG_CHAT   |        Unmutes a player on chat.       |
|     !silence     |    ADMFLAG_CHAT   |    Mutes a player on voice and chat.   |
|    !unsilence    |    ADMFLAG_CHAT   |   Unmutes a player on voice and chat.  |
|       !ban       |    ADMFLAG_BAN    | Bans a player from joining the server. |
|      !unban      |   ADMFLAG_UNBAN   |            Unbans a player.            |
|       !kick      |    ADMFLAG_KICK   |     Kicks a player from the server.    |

### Creating A Pull Request 😃

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

### Have ideas? 💡
Join [Swiftly Discord Server](https://swiftlycs2.net/discord)!