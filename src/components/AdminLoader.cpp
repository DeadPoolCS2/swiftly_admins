#include <main.h>
#include <swiftly/swiftly.h>
#include <swiftly/configuration.h>
#include <swiftly/database.h>
#include <swiftly/logger.h>
#include <set>

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

            std::set<int> giveFlags;

            for (int i = 0; i < flags.size(); i++)
            {
                if (flags.at(i) == 'a')
                    giveFlags.insert(ADMFLAG_RESERVATION);
                else if (flags.at(i) == 'b')
                    giveFlags.insert(ADMFLAG_GENERIC);
                else if (flags.at(i) == 'c')
                    giveFlags.insert(ADMFLAG_KICK);
                else if (flags.at(i) == 'd')
                    giveFlags.insert(ADMFLAG_BAN);
                else if (flags.at(i) == 'e')
                    giveFlags.insert(ADMFLAG_UNBAN);
                else if (flags.at(i) == 'f')
                    giveFlags.insert(ADMFLAG_SLAY);
                else if (flags.at(i) == 'g')
                    giveFlags.insert(ADMFLAG_CHANGEMAP);
                else if (flags.at(i) == 'h')
                    giveFlags.insert(ADMFLAG_CONVARS);
                else if (flags.at(i) == 'i')
                    giveFlags.insert(ADMFLAG_CONFIG);
                else if (flags.at(i) == 'j')
                    giveFlags.insert(ADMFLAG_CHAT);
                else if (flags.at(i) == 'k')
                    giveFlags.insert(ADMFLAG_VOTE);
                else if (flags.at(i) == 'l')
                    giveFlags.insert(ADMFLAG_PASSWORD);
                else if (flags.at(i) == 'm')
                    giveFlags.insert(ADMFLAG_RCON);
                else if (flags.at(i) == 'n')
                    giveFlags.insert(ADMFLAG_CHEATS);
                else if (flags.at(i) == 'o')
                    giveFlags.insert(ADMFLAG_CUSTOM1);
                else if (flags.at(i) == 'p')
                    giveFlags.insert(ADMFLAG_CUSTOM2);
                else if (flags.at(i) == 'q')
                    giveFlags.insert(ADMFLAG_CUSTOM3);
                else if (flags.at(i) == 'r')
                    giveFlags.insert(ADMFLAG_CUSTOM4);
                else if (flags.at(i) == 's')
                    giveFlags.insert(ADMFLAG_CUSTOM5);
                else if (flags.at(i) == 't')
                    giveFlags.insert(ADMFLAG_CUSTOM6);
                else if (flags.at(i) == 'z')
                    giveFlags.insert(ADMFLAG_ROOT);
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