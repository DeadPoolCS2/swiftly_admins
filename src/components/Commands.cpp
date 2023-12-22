#include <swiftly/swiftly.h>
#include <swiftly/commands.h>
#include <swiftly/configuration.h>
#include <swiftly/server.h>
#include <swiftly/timers.h>
#include <swiftly/database.h>
#include <main.h>

uint16_t elapsedTime = 0;
uint64_t mapTimerID = 0;
std::string change_map_to = "";

void ChangeMapThread()
{
    --elapsedTime;
    if (elapsedTime == 0)
    {
        server->ChangeLevel(change_map_to.c_str());
        timers->DestroyTimer(mapTimerID);
        mapTimerID = 0;
    }
}

std::string ComputeSanctionTime(uint32_t seconds)
{
    std::string return_time;
    if (seconds == 0)
        return_time = FetchTranslation("admins.forever");
    else
    {
        float time = (float)seconds;
        if (time < 60)
            return_time = format(FetchTranslation("admins.seconds"), time);
        else if (time < 3600)
            return_time = format(FetchTranslation("admins.minutes"), time / 60);
        else if (time < 86400)
            return_time = format(FetchTranslation("admins.hours"), time / 3600);
        else
            return_time = format(FetchTranslation("admins.days"), time / 86400);
    }
    return return_time;
}

void Command_ReloadAdmins(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        LoadAdmins();
        ReloadServerAdmins();

        print(FetchTranslation("admins.reloadadmins"), config->Fetch<const char *>("admins.prefix"));
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_ROOT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        LoadAdmins();
        ReloadServerAdmins();

        player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.reloadadmins"), config->Fetch<const char *>("admins.prefix"));
    }
}

void Command_Slay(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.slay.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        player->Kill();
        print(FetchTranslation("admins.player_slayed"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_slayed"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_SLAY))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.slay.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        targetPlayer->Kill();
        print(FetchTranslation("admins.player_slayed"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_slayed"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());
    }
}

void Command_Chat(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.chat.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();

        const char *sendmsg = format(FetchTranslation("admins.chat.admin_chat"), "CONSOLE", message);
        for (uint16_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
        {
            Player *admin = g_playerManager->GetPlayer(i);
            if (admin == nullptr)
                continue;

            if ((admin->vars->Get<int>("admin.flags") & ADMFLAG_CHAT) == ADMFLAG_CHAT)
                admin->SendMsg(HUD_PRINTTALK, sendmsg);
        }
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.chat.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        const char *sendmsg = format(FetchTranslation("admins.chat.admin_chat"), player->GetName(), message);

        for (uint16_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
        {
            Player *admin = g_playerManager->GetPlayer(i);
            if (admin == nullptr)
                continue;

            if ((admin->vars->Get<int>("admin.flags") & ADMFLAG_CHAT) == ADMFLAG_CHAT)
                admin->SendMsg(HUD_PRINTTALK, sendmsg);
        }
    }
}

void Command_CenterSay(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.csay.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTCENTER, "%s: %s", "CONSOLE", message);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.csay.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTCENTER, "%s: %s", player->GetName(), message);
    }
}

void Command_Say(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.say.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTCENTER, FetchTranslation("admins.say.message"), "CONSOLE", message);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.say.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        std::string final_message;
        for (uint32_t i = 0; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.say.message"), player->GetName(), message);
    }
}

void Command_PrivateSay(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 2)
            return print(FetchTranslation("admins.psay.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        std::string final_message;
        for (uint32_t i = 1; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        player->SendMsg(HUD_PRINTCENTER, FetchTranslation("admins.psay.message"), "CONSOLE", message);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 2)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.psay.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        std::string final_message;
        for (uint32_t i = 1; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *message = final_message.c_str();
        targetPlayer->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.psay.message"), player->GetName(), message);
    }
}

void Command_Rcon(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
        return;

    Player *player = g_playerManager->GetPlayer(playerID);
    if (player == nullptr)
        return;

    if (!PLAYER_HAS_FLAG(ADMFLAG_RCON))
        return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

    if (argsCount < 1)
        return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.rcon.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

    std::string final_message;
    for (uint32_t i = 0; i < argsCount; i++)
        final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

    if (final_message.rfind("sw ", 0) == 0)
        return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

    server->ExecuteCommand(final_message.c_str());
}

void Command_ChangeMap(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.changemap.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        std::string map = args[0];
        if (!server->IsMapValid(map.c_str()))
            return print(FetchTranslation("admins.invalid_map"), config->Fetch<const char *>("admins.prefix"), map.c_str());

        print(FetchTranslation("admins.changing_map"), config->Fetch<const char *>("admins.prefix"), map.c_str());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.changing_map"), config->Fetch<const char *>("admins.prefix"), map.c_str());
        elapsedTime = 5;
        change_map_to = map;

        if (mapTimerID == 0)
            timers->RegisterTimer(1000, ChangeMapThread);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHANGEMAP))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.changemap.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        std::string map = args[0];
        if (!server->IsMapValid(map.c_str()))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_map"), config->Fetch<const char *>("admins.prefix"), map.c_str());

        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.changing_map"), config->Fetch<const char *>("admins.prefix"), map.c_str());
        elapsedTime = 5;
        change_map_to = map;

        if (mapTimerID == 0)
            timers->RegisterTimer(1000, ChangeMapThread);
    }
}

void Command_Kick(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 2)
            return print(FetchTranslation("admins.kick.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        std::string final_message;
        for (uint32_t i = 1; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        print(FetchTranslation("admins.kick.message"), "CONSOLE", player->GetName(), reason);
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.kick.message"), "CONSOLE", player->GetName(), reason);
        player->Drop(NETWORK_DISCONNECT_KICKED);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_KICK))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 2)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.kick.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        std::string final_message;
        for (uint32_t i = 1; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.kick.message"), player->GetName(), targetPlayer->GetName(), reason);
        targetPlayer->Drop(NETWORK_DISCONNECT_KICKED);
    }
}

void Command_Mute(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 3)
            return print(FetchTranslation("admins.mute.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.ismuted") == true)
            return print(FetchTranslation("admins.player_already_muted"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return print(FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        print(FetchTranslation("admins.mute.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.mute.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformMute(player, 0, time * 60, reason, true);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 3)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.mute.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.ismuted") == true)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_already_muted"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.mute.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformMute(targetPlayer, player->GetSteamID(), time * 60, reason, true);
    }
}

void Command_Unmute(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.unmute.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.ismuted") == false)
            return print(FetchTranslation("admins.player_not_muted"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        print(FetchTranslation("admins.unmute.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unmute.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());

        PerformUnmute(player);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unmute.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.ismuted") == false)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_muted"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unmute.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());

        PerformUnmute(targetPlayer);
    }
}

void Command_Gag(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 3)
            return print(FetchTranslation("admins.gag.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.isgagged") == true)
            return print(FetchTranslation("admins.player_already_gagged"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return print(FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        print(FetchTranslation("admins.gag.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.gag.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformGag(player, 0, time * 60, reason, true);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 3)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.gag.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.isgagged") == true)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_already_gagged"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.gag.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformGag(targetPlayer, player->GetSteamID(), time * 60, reason, true);
    }
}

void Command_Ungag(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.ungag.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.isgagged") == false)
            return print(FetchTranslation("admins.player_not_gagged"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        print(FetchTranslation("admins.ungag.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ungag.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());

        PerformUngag(player);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ungag.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.isgagged") == false)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_gagged"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ungag.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());

        PerformUngag(targetPlayer);
    }
}

void Command_Silence(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 3)
            return print(FetchTranslation("admins.silence.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.isgagged") == true || player->vars->Get<bool>("sanctions.ismuted") == true)
            return print(FetchTranslation("admins.player_already_gagged_or_muted"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return print(FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        print(FetchTranslation("admins.silence.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.silence.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformGag(player, 0, time * 60, reason, true);
        PerformMute(player, 0, time * 60, reason, true);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 3)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.silence.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.isgagged") == true || targetPlayer->vars->Get<bool>("sanctions.ismuted") == true)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_already_gagged_or_muted"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        int time = StringToInt(args[1]);
        if (time < 0 || time > 1440)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 1440);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.silence.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformGag(targetPlayer, player->GetSteamID(), time * 60, reason, true);
        PerformMute(targetPlayer, player->GetSteamID(), time * 60, reason, true);
    }
}

void Command_Unsilence(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.unsilence.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (player->vars->Get<bool>("sanctions.isgagged") == false || player->vars->Get<bool>("sanctions.isgagged") == false)
            return print(FetchTranslation("admins.player_not_gagged_and_muted"), config->Fetch<const char *>("admins.prefix"), player->GetName());

        print(FetchTranslation("admins.unsilence.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unsilence.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());

        PerformUngag(player);
        PerformUnmute(player);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_CHAT))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unsilence.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        if (targetPlayer->vars->Get<bool>("sanctions.isgagged") == false || player->vars->Get<bool>("sanctions.isgagged") == false)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_gagged_and_muted"), config->Fetch<const char *>("admins.prefix"), targetPlayer->GetName());

        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unsilence.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());
        PerformUngag(targetPlayer);
        PerformUnmute(targetPlayer);
    }
}

void Command_Ban(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 3)
            return print(FetchTranslation("admins.ban.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        int time = StringToInt(args[1]);
        if (time < 0 || time > 365)
            return print(FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 365);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        print(FetchTranslation("admins.ban.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ban.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformBan(player->GetSteamID(), 0, time * 86400, reason);
        player->Drop(NETWORK_DISCONNECT_KICKBANADDED);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_BAN))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 3)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ban.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        int time = StringToInt(args[1]);
        if (time < 0 || time > 365)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_time"), config->Fetch<const char *>("admins.prefix"), 1, 365);

        std::string final_message;
        for (uint32_t i = 2; i < argsCount; i++)
            final_message += (std::string(args[i]) + (i == argsCount - 1 ? "" : " "));

        const char *reason = final_message.c_str();
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.ban.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName(), ComputeSanctionTime(time * 60).c_str(), reason);

        PerformBan(targetPlayer->GetSteamID(), player->GetSteamID(), time * 86400, reason);
        targetPlayer->Drop(NETWORK_DISCONNECT_KICKBANADDED);
    }
}

void Command_Unban(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.unban.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        uint64_t target = StringToULongLong(args[0]);
        print(FetchTranslation("admins.unban.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", target);

        PerformUnban(target, 0);
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_UNBAN))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unban.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        uint64_t target = StringToULongLong(args[0]);
        player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.unban.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), target);
        PerformUnban(target, player->GetSteamID());
    }
}

void Command_Slap(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID == -1)
    {
        if (argsCount < 1)
            return print(FetchTranslation("admins.slap.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return print(FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *player = g_playerManager->GetPlayer(target);
        if (player == nullptr)
            return print(FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        Vector *coords = player->coords->Get();
        coords->z += 25.0f;
        player->coords->Set(coords);

        print(FetchTranslation("admins.slap.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.slap.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", player->GetName());
    }
    else
    {
        Player *player = g_playerManager->GetPlayer(playerID);
        if (player == nullptr)
            return;

        if (!PLAYER_HAS_FLAG(ADMFLAG_SLAY))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.no_access"), config->Fetch<const char *>("admins.prefix"));

        if (argsCount < 1)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.slap.syntax"), config->Fetch<const char *>("admins.prefix"), std::string(1, std::string(config->Fetch<const char *>(silent ? "core.silentCommandPrefixes" : "core.commandPrefixes")).at(0)).c_str());

        int target = GetPlayerId(args[0]);
        if (target < 0 || target >= MAX_PLAYERS)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.invalid_player"), config->Fetch<const char *>("admins.prefix"));

        Player *targetPlayer = g_playerManager->GetPlayer(target);
        if (targetPlayer == nullptr)
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.player_not_connected"), config->Fetch<const char *>("admins.prefix"), target);

        if (targetPlayer->vars->Get<int>("admin.immunity") > player->vars->Get<int>("admin.immunity"))
            return player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.cannot_use_command"), config->Fetch<const char *>("admins.prefix"));

        Vector *coords = targetPlayer->coords->Get();
        coords->z += 25.0f;
        targetPlayer->coords->Set(coords);

        g_playerManager->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.slap.message"), config->Fetch<const char *>("admins.prefix"), player->GetName(), targetPlayer->GetName());
    }
}

void Command_AddAdmin(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID != -1)
        return;

    if (argsCount < 3)
        return print(FetchTranslation("admins.addadmin.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

    uint64_t steamid = StringToULongLong(args[0]);
    std::string flags = args[1];
    int immunity = StringToInt(args[2]);

    if (immunity < 0)
        return print(FetchTranslation("admins.invalid_immunity"), config->Fetch<const char *>("admins.prefix"));

    if (!HasValidFlags(flags))
        return print(FetchTranslation("admins.invalid_flags"), config->Fetch<const char *>("admins.prefix"));

    if (admins.find(steamid) != admins.end())
        return print(FetchTranslation("admins.already_has_admin"), config->Fetch<const char *>("admins.prefix"), steamid);

    db->Query("insert into %s (steamid, flags, immunity) values ('%llu', '%s', '%d')", config->Fetch<const char *>("admins.table_name.admins"), steamid, flags.c_str(), immunity);
    ReloadServerAdmins();
    print(FetchTranslation("admins.addadmin.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", steamid, flags.c_str(), immunity);
}

void Command_RemoveAdmin(int playerID, const char **args, uint32_t argsCount, bool silent)
{
    if (playerID != -1)
        return;

    if (argsCount < 1)
        return print(FetchTranslation("admins.removeadmin.syntax"), config->Fetch<const char *>("admins.prefix"), "sw_");

    uint64_t steamid = StringToULongLong(args[0]);

    if (admins.find(steamid) == admins.end())
        return print(FetchTranslation("admins.is_not_an_admin"), config->Fetch<const char *>("admins.prefix"), steamid);

    db->Query("delete from %s where steamid = '%llu' limit 1", config->Fetch<const char *>("admins.table_name.admins"), steamid);
    ReloadServerAdmins();
    print(FetchTranslation("admins.removeadmin.message"), config->Fetch<const char *>("admins.prefix"), "CONSOLE", steamid);
}

void RegisterCommands()
{
    commands->Register("reloadadmins", reinterpret_cast<void *>(&Command_ReloadAdmins));
    commands->Register("addadmin", reinterpret_cast<void *>(&Command_AddAdmin));
    commands->Register("removeadmin", reinterpret_cast<void *>(&Command_RemoveAdmin));
    commands->Register("rcon", reinterpret_cast<void *>(&Command_Rcon));

    commands->Register("slay", reinterpret_cast<void *>(&Command_Slay));
    commands->Register("slap", reinterpret_cast<void *>(&Command_Slap));

    commands->Register("map", reinterpret_cast<void *>(&Command_ChangeMap));
    commands->Register("changemap", reinterpret_cast<void *>(&Command_ChangeMap));

    commands->Register("chat", reinterpret_cast<void *>(&Command_Chat));
    commands->Register("csay", reinterpret_cast<void *>(&Command_CenterSay));
    commands->Register("say", reinterpret_cast<void *>(&Command_Say));
    commands->Register("psay", reinterpret_cast<void *>(&Command_PrivateSay));

    commands->Register("mute", reinterpret_cast<void *>(&Command_Mute));
    commands->Register("unmute", reinterpret_cast<void *>(&Command_Unmute));

    commands->Register("gag", reinterpret_cast<void *>(&Command_Gag));
    commands->Register("ungag", reinterpret_cast<void *>(&Command_Ungag));

    commands->Register("silence", reinterpret_cast<void *>(&Command_Silence));
    commands->Register("unsilence", reinterpret_cast<void *>(&Command_Unsilence));

    commands->Register("ban", reinterpret_cast<void *>(&Command_Ban));
    commands->Register("unban", reinterpret_cast<void *>(&Command_Unban));

    commands->Register("kick", reinterpret_cast<void *>(&Command_Kick));
}