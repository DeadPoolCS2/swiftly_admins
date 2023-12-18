#ifndef _swiftly_admins_h
#define _swiftly_admins_h

#define PLAYER_HAS_FLAG(flag) ((player->vars->Get<int>("admin.flags") & flag) == flag)

#define ADMFLAG_RESERVATION (1 << 0) // a - Reserved Slot
#define ADMFLAG_GENERIC (1 << 1)     // b - Generic Admin; Access to u@
#define ADMFLAG_KICK (1 << 2)        // c - Kick players
#define ADMFLAG_BAN (1 << 3)         // d - Ban players
#define ADMFLAG_UNBAN (1 << 4)       // e - Unban players
#define ADMFLAG_SLAY (1 << 5)        // f - Slay
#define ADMFLAG_CHANGEMAP (1 << 6)   // g - Change map
#define ADMFLAG_CONVARS (1 << 7)     // h - Change server cvars
#define ADMFLAG_CONFIG (1 << 8)      // i - Executes commands over plugin specific config files
#define ADMFLAG_CHAT (1 << 9)        // j - Access to private say, center say, etc.
#define ADMFLAG_VOTE (1 << 10)       // k - Creates a vote on server
#define ADMFLAG_PASSWORD (1 << 11)   // l - Changes server's password
#define ADMFLAG_RCON (1 << 12)       // m - Use RCON commands
#define ADMFLAG_CHEATS (1 << 13)     // n - Changes sv_cheats and allows to use cheating commands (noclip, etc)
#define ADMFLAG_ROOT (1 << 14)       // z - Access to everything
#define ADMFLAG_CUSTOM1 (1 << 15)    // o - Custom Flag 1
#define ADMFLAG_CUSTOM2 (1 << 16)    // p - Custom Flag 2
#define ADMFLAG_CUSTOM3 (1 << 17)    // q - Custom Flag 3
#define ADMFLAG_CUSTOM4 (1 << 18)    // r - Custom Flag 4
#define ADMFLAG_CUSTOM5 (1 << 19)    // s - Custom Flag 5
#define ADMFLAG_CUSTOM6 (1 << 20)    // t - Custom Flag 6

#endif