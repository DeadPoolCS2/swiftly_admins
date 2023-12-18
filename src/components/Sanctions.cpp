#include <main.h>
#include <swiftly/swiftly.h>
#include <swiftly/commands.h>
#include <swiftly/database.h>
#include <swiftly/logger.h>
#include <swiftly/configuration.h>

std::map<uint64_t, Player *> playersToCheckForSanctions;

std::string ComputeTime(uint64_t time)
{
    std::string return_time;
    if (time == 0)
        return_time = FetchTranslation("admins.never");
    else
    {
        float seconds = (float)((time - GetTime()) / 1000);

        if (seconds < 60)
            return_time = format(FetchTranslation("admins.seconds"), seconds);
        else if (seconds < 3600)
            return_time = format(FetchTranslation("admins.minutes"), seconds / 60);
        else if (seconds < 86400)
            return_time = format(FetchTranslation("admins.hours"), seconds / 3600);
        else
            return_time = format(FetchTranslation("admins.days"), seconds / 86400);
    }
    return return_time;
}

void CheckSanctions(Player *player)
{
    player->vars->Set("sanctions.isgagged", false);
    player->vars->Set<int64_t>("sanctions.gag.expire_time", (int64_t)0);
    player->vars->Set("sanctions.gag.reason", "");
    player->vars->Set("sanctions.gagid", 0);

    player->vars->Set("sanctions.ismuted", false);
    player->vars->Set<int64_t>("sanctions.mute.expire_time", (int64_t)0);
    player->vars->Set("sanctions.mute.reason", "");
    player->vars->Set("sanctions.muteid", 0);

    DB_Result sanctions = db->Query("select * from %s where sanction_player = '%llu' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0) order by id", config->Fetch<const char *>("admins.table_name.sanctions"), player->GetSteamID());
    if (sanctions.size() > 0)
    {
        for (uint32_t i = 0; i < sanctions.size(); i++)
        {
            int id = db->fetchValue<int>(sanctions, i, "id");
            int type = db->fetchValue<int>(sanctions, i, "sanction_type");
            int expiretime = db->fetchValue<int>(sanctions, i, "sanction_expiretime");
            const char *reason = db->fetchValue<const char *>(sanctions, i, "sanction_reason");

            if (type == SANCTION_BAN)
                return player->Drop(NETWORK_DISCONNECT_KICKBANADDED);
            else if (type == SANCTION_GAG)
            {
                PerformGag(player, 0, expiretime == 0 ? 0 : ((((uint64_t)expiretime * 1000) - GetTime()) / 1000), reason, false);
                player->vars->Set("sanctions.gagid", id);
            }
            else if (type == SANCTION_MUTE)
            {
                PerformMute(player, 0, expiretime == 0 ? 0 : ((((uint64_t)expiretime * 1000) - GetTime()) / 1000), reason, false);
                player->vars->Set("sanctions.muteid", id);
            }
        }
    }
}

void OnGameTick(bool simulating, bool bFirstTick, bool bLastTick)
{
    if (!db->IsConnected())
        return;

    if (playersToCheckForSanctions.size() > 0)
    {
        for (std::map<uint64_t, Player *>::iterator it = playersToCheckForSanctions.begin(); it != playersToCheckForSanctions.end(); ++it)
        {
            Player *player = it->second;
            if (player->IsAuthenticated())
            {
                CheckSanctions(player);
                playersToCheckForSanctions.erase(it);
            }
        }
    }
}

void PrintSanctions(Player *player)
{
    if (player->vars->Get<bool>("sanctions.isgagged") == true)
    {
        std::string time = ComputeTime(player->vars->Get<int64_t>("sanctions.gag.expire_time"));
        std::string reason = player->vars->Get<const char *>("sanctions.gag.reason");
        player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.gagged"), config->Fetch<const char *>("admins.prefix"), time.c_str(), reason.c_str());
    }
    if (player->vars->Get<bool>("sanctions.ismuted") == true)
    {
        std::string time = ComputeTime(player->vars->Get<int64_t>("sanctions.mute.expire_time"));
        std::string reason = player->vars->Get<const char *>("sanctions.mute.reason");
        player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.muted"), config->Fetch<const char *>("admins.prefix"), time.c_str(), reason.c_str());
    }
}

void OnPlayerSpawn(Player *player)
{
    if (player->IsFirstSpawn())
        PrintSanctions(player);
}

void ReloadSanctions()
{
    for (uint16_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
    {
        Player *player = g_playerManager->GetPlayer(i);
        if (player == nullptr)
            continue;
        if (player->IsFakeClient())
            continue;

        CheckSanctions(player);
        PrintSanctions(player);
    }
}

void SanctionExpireCheck()
{
    if (!db->IsConnected())
        return;

    for (uint32_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
    {
        Player *player = g_playerManager->GetPlayer(i);
        if (player == nullptr)
            continue;
        if (player->IsFakeClient())
            continue;

        CheckExpiredSanctions(player, true);
    }
}

void CheckExpiredSanctions(Player *player, bool sendmessage)
{
    if (player->vars->Get<bool>("sanctions.isgagged") == true && (player->vars->Get<int64_t>("sanctions.gag.expire_time") - (int64_t)GetTime() <= 0) && player->vars->Get<int64_t>("sanctions.gag.expire_time") != 0)
    {
        player->vars->Set("sanctions.isgagged", false);
        player->vars->Set<int64_t>("sanctions.gag.expire_time", (int64_t)0);
        player->vars->Set("sanctions.gag.reason", "");
        db->Query("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config->Fetch<const char *>("admins.table_name.sanctions"), GetTime() / 1000, player->vars->Get<int>("sanctions.gagid"));
        player->vars->Set("sanctions.gagid", 0);

        if (sendmessage)
            player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.gag_expired"), config->Fetch<const char *>("admins.prefix"));
    }

    if (player->vars->Get<bool>("sanctions.ismuted") == true && (player->vars->Get<int64_t>("sanctions.mute.expire_time") - (int64_t)GetTime() <= 0) && player->vars->Get<int64_t>("sanctions.mute.expire_time") != 0)
    {
        player->vars->Set("sanctions.ismuted", false);
        player->vars->Set<int64_t>("sanctions.mute.expire_time", (int64_t)0);
        player->vars->Set("sanctions.mute.reason", "");
        db->Query("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config->Fetch<const char *>("admins.table_name.sanctions"), GetTime() / 1000, player->vars->Get<int>("sanctions.muteid"));
        player->vars->Set("sanctions.muteid", 0);

        if (sendmessage)
            player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.mute_expired"), config->Fetch<const char *>("admins.prefix"));
    }
}

void PerformMute(Player *player, uint64_t admin_steamid, int seconds, std::string reason, bool query)
{
    if (query)
    {
        if (db->IsConnected())
        {
            db->Query("update %s set sanction_expiretime = '%d' where sanction_player = '%llu' and sanction_type = '%d' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0)",
                      config->Fetch<const char *>("admins.table_name.sanctions"), (GetTime() / 1000), player->GetSteamID(), SANCTION_MUTE);

            DB_Result result = db->Query("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%llu', '%d', '%d', '%d', '%s', '%s')",
                                         config->Fetch<const char *>("admins.table_name.sanctions"), player->GetSteamID(), SANCTION_MUTE, seconds == 0 ? 0 : (GetTime() / 1000) + seconds, seconds, reason.c_str(), admin_steamid == 0 ? "-1" : std::to_string(admin_steamid).c_str());

            if (result.size() > 0)
            {
                int insertID = db->fetchValue<int>(result, 0, "insertId");
                player->vars->Set("sanctions.muteid", insertID);
            }
        }
    }

    player->vars->Set("sanctions.ismuted", true);
    player->vars->Set<int64_t>("sanctions.mute.expire_time", seconds == 0 ? 0 : ((int64_t)GetTime() + (int64_t)(seconds * 1000)));
    player->vars->Set("sanctions.mute.reason", reason.c_str());
}

void PerformGag(Player *player, uint64_t admin_steamid, int seconds, std::string reason, bool query)
{
    if (query)
    {
        if (db->IsConnected())
        {
            db->Query("update %s set sanction_expiretime = '%d' where sanction_player = '%llu' and sanction_type = '%d' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0)",
                      config->Fetch<const char *>("admins.table_name.sanctions"), (GetTime() / 1000), player->GetSteamID(), SANCTION_GAG);

            DB_Result result = db->Query("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%llu', '%d', '%d', '%d', '%s', '%s')",
                                         config->Fetch<const char *>("admins.table_name.sanctions"), player->GetSteamID(), SANCTION_GAG, seconds == 0 ? 0 : (GetTime() / 1000) + seconds, seconds, reason.c_str(), admin_steamid == 0 ? "-1" : std::to_string(admin_steamid).c_str());

            if (result.size() > 0)
            {
                int insertID = db->fetchValue<int>(result, 0, "insertId");
                player->vars->Set("sanctions.gagid", insertID);
            }
        }
    }

    player->vars->Set("sanctions.isgagged", true);
    player->vars->Set<int64_t>("sanctions.gag.expire_time", seconds == 0 ? 0 : (int64_t)GetTime() + (int64_t)(seconds * 1000));
    player->vars->Set("sanctions.gag.reason", reason.c_str());
}

void PerformUngag(Player *player)
{
    player->vars->Set("sanctions.isgagged", false);
    player->vars->Set<int64_t>("sanctions.gag.expire_time", (int64_t)0);
    player->vars->Set("sanctions.gag.reason", "");
    if (player->vars->Get<int>("sanctions.gagid") != 0)
    {
        db->Query("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config->Fetch<const char *>("admins.table_name.sanctions"), GetTime() / 1000, player->vars->Get<int>("sanctions.gagid"));
        player->vars->Set("sanctions.gagid", 0);
    }
}

void PerformUnmute(Player *player)
{
    player->vars->Set("sanctions.ismuted", false);
    player->vars->Set<int64_t>("sanctions.mute.expire_time", (int64_t)0);
    player->vars->Set("sanctions.mute.reason", "");
    if (player->vars->Get<int>("sanctions.muteid") != 0)
    {
        db->Query("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config->Fetch<const char *>("admins.table_name.sanctions"), GetTime() / 1000, player->vars->Get<int>("sanctions.muteid"));
        player->vars->Set("sanctions.muteid", 0);
    }
}

void PerformBan(uint64_t player_steamid, uint64_t admin_steamid, int seconds, std::string reason)
{
    if (db->IsConnected())
    {
        db->Query("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%llu', '%d', '%d', '%d', '%s', '%s')",
                  config->Fetch<const char *>("admins.table_name.sanctions"), player_steamid, SANCTION_BAN, seconds == 0 ? 0 : (GetTime() / 1000) + seconds, seconds, reason.c_str(), admin_steamid == 0 ? "-1" : std::to_string(admin_steamid).c_str());

        logger->Write(LOGLEVEL_COMMON, "'%s' banned '%s'. Time: %s | Reason: %s", admin_steamid == 0 ? "CONSOLE" : std::to_string(admin_steamid).c_str(), std::to_string(player_steamid).c_str(), ComputeSanctionTime(seconds).c_str(), reason.c_str());
    }
}

void PerformUnban(uint64_t player_steamid, uint64_t admin_steamid)
{
    if (db->IsConnected())
    {
        db->Query("update %s set sanction_expiretime = '%d' where sanction_player = '%llu' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0) and sanction_type = '%d'", config->Fetch<const char *>("admins.table_name.sanctions"), GetTime() / 1000, std::to_string(player_steamid).c_str(), SANCTION_BAN);
        logger->Write(LOGLEVEL_COMMON, "'%s' unbanned '%s'.", admin_steamid == 0 ? "CONSOLE" : std::to_string(admin_steamid).c_str(), std::to_string(player_steamid).c_str());
    }
}