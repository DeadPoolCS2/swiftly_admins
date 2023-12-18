#include <swiftly/swiftly.h>
#include <swiftly/configuration.h>
#include <main.h>

bool OnClientConnect(Player *player)
{
    LoadAdmin(player);
    playersToCheckForSanctions.insert(std::make_pair(player->GetSteamID(), player));
    return true;
}

void OnClientDisconnect(Player *player)
{
    player->vars->Set("admin.flags", 0);
    player->vars->Set("admin.immunity", 0);
}

bool OnPlayerChat(Player *player, const char *text, bool teamonly)
{
    if (teamonly && text[0] == '@')
    {
        if (player->vars->Get<int>("admin.flags") == 0)
            player->SendMsg(HUD_PRINTTALK, FetchTranslation("admins.chat.to_admins"), player->GetName(), text + 1);

        const char *sendmsg = format(FetchTranslation("admins.chat.admin_chat"), player->GetName(), text + 1);
        for (uint16_t i = 0; i < g_playerManager->GetPlayerCap(); i++)
        {
            Player *admin = g_playerManager->GetPlayer(i);
            if (admin == nullptr)
                continue;

            if ((admin->vars->Get<int>("admin.flags") & ADMFLAG_CHAT) == ADMFLAG_CHAT)
                admin->SendMsg(HUD_PRINTTALK, sendmsg);
        }

        return false;
    }

    if (player->vars->Get<bool>("sanctions.isgagged"))
        return false;

    return true;
}

bool ShouldHearVoice(Player *player)
{
    if (player->vars->Get<bool>("sanctions.ismuted"))
        return false;

    return true;
}