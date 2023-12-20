#include <main.h>
#include <swiftly/swiftly.h>
#include <swiftly/configuration.h>
#include <swiftly/database.h>
#include <swiftly/logger.h>
#include <set>

const std::map<int, int> flagsPermissions = {
    {'a', ADMFLAG_RESERVATION},
    {'b', ADMFLAG_GENERIC},
    {'c', ADMFLAG_KICK},
    {'d', ADMFLAG_BAN},
    {'e', ADMFLAG_UNBAN},
    {'f', ADMFLAG_SLAY},
    {'g', ADMFLAG_CHANGEMAP},
    {'h', ADMFLAG_CONVARS},
    {'i', ADMFLAG_CONFIG},
    {'j', ADMFLAG_CHAT},
    {'k', ADMFLAG_VOTE},
    {'l', ADMFLAG_PASSWORD},
    {'m', ADMFLAG_RCON},
    {'n', ADMFLAG_CHEATS},
    {'o', ADMFLAG_CUSTOM1},
    {'p', ADMFLAG_CUSTOM2},
    {'q', ADMFLAG_CUSTOM3},
    {'r', ADMFLAG_CUSTOM4},
    {'s', ADMFLAG_CUSTOM5},
    {'t', ADMFLAG_CUSTOM6},
    {'z', ADMFLAG_ROOT},
};

int ProcessFlags(std::set<int> giveFlags)
{
    int flags = 0;

    for (std::set<int>::iterator it = giveFlags.begin(); it != giveFlags.end(); ++it)
    {
        int giveFlag = *it;
        if ((giveFlag & ADMFLAG_ROOT) == ADMFLAG_ROOT)
        {
            flags |= ADMFLAG_RESERVATION;
            flags |= ADMFLAG_GENERIC;
            flags |= ADMFLAG_KICK;
            flags |= ADMFLAG_BAN;
            flags |= ADMFLAG_UNBAN;
            flags |= ADMFLAG_SLAY;
            flags |= ADMFLAG_CHANGEMAP;
            flags |= ADMFLAG_CONVARS;
            flags |= ADMFLAG_CONFIG;
            flags |= ADMFLAG_CHAT;
            flags |= ADMFLAG_VOTE;
            flags |= ADMFLAG_PASSWORD;
            flags |= ADMFLAG_RCON;
            flags |= ADMFLAG_CHEATS;
            flags |= ADMFLAG_ROOT;
        }
        else
            flags |= giveFlag;
    }

    return flags;
}

void LoadAdmins()
{
    admins.clear();
    adminImmunities.clear();

    if (!db->IsConnected())
        return;

    DB_Result result = db->Query("select * from %s", config->Fetch<const char *>("admins.table_name.admins"));
    if (result.size() > 0)
    {
        for (uint32_t i = 0; i < result.size(); i++)
        {
            uint64_t steamid = std::stoull(db->fetchValue<const char *>(result, i, "steamid"));
            int immunity = db->fetchValue<int>(result, i, "immunity");
            std::string flags = db->fetchValue<const char *>(result, i, "flags");

            if (immunity < 0)
            {
                logger->Write(LOGLEVEL_WARNING, "Immunity for '%llu' can't be negative, automatically setting it to 0\n", steamid);
                immunity = 0;
            }

            std::set<int> giveFlags;

            for (int i = 0; i < flags.size(); i++)
            {
                if (flagsPermissions.find(flags.at(i)) != flagsPermissions.end())
                    giveFlags.insert(flagsPermissions.at(flags.at(i)));
                else
                    logger->Write(LOGLEVEL_WARNING, "Invalid flag for '%llu': '%c'\n", steamid, flags.at(i));
            }

            int toGiveFlags = ProcessFlags(giveFlags);
            giveFlags.clear();

            admins.insert(std::make_pair(steamid, toGiveFlags));
            adminImmunities.insert(std::make_pair(steamid, immunity));
        }
    }
}

void LoadAdmin(Player *player)
{
    player->vars->Set("admin.flags", 0);
    player->vars->Set("admin.immunity", 0);

    uint64_t steamid = player->GetSteamID();

    if (admins.find(steamid) != admins.end())
    {
        player->vars->Set("admin.flags", admins.at(steamid));
        player->vars->Set("admin.immunity", adminImmunities.at(steamid));
    }
}

void ReloadServerAdmins()
{
    for (uint32_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
    {
        Player *player = g_playerManager->GetPlayer(i);
        if (player == nullptr)
            continue;
        if (player->IsFakeClient())
            continue;

        LoadAdmin(player);
    }
}

bool HasValidFlags(std::string flags)
{
    for (uint32_t i = 0; i < flags.size(); i++)
        if (flagsPermissions.find(flags.at(i)) == flagsPermissions.end())
            return false;

    return true;
}