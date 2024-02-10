function ComputeTime(time)
    if time == 0 then return FetchTranslation("admins.never") end

    local seconds = math.floor((time - GetTime()) / 1000)

    if seconds < 60 then return string.format(FetchTranslation("admins.seconds"), seconds)
    elseif seconds < 3600 then return string.format(FetchTranslation("admins.minutes"), math.floor(seconds / 60))
    elseif seconds < 86400 then return string.format(FetchTranslation("admins.hours"), math.floor(seconds / 3600))
    else return string.format(FetchTranslation("admins.days"), math.floor(seconds / 86400)) end
end

function CheckSanctions(player)
    player:vars():Set("sanctions.isgagged", false)
    player:vars():Set("sanctions.gag.expire_time", 0)
    player:vars():Set("sanctions.gag.reason", "")
    player:vars():Set("sanctions.gagid", 0)
    player:vars():Set("sanctions.ismuted", false)
    player:vars():Set("sanctions.mute.expire_time", 0)
    player:vars():Set("sanctions.mute.reason", "")
    player:vars():Set("sanctions.muteid", 0)

    local sanctions = db:Query(string.format("select * from %s where sanction_player = '%.0f' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0) order by id", config:Fetch("admins.table_name.sanctions"), player:GetSteamID()))
    if #sanctions > 0 then
        for i=1,#sanctions do 
            local id = sanctions[i].id
            local sanction_type = sanctions[i].sanction_type
            local expiretime = sanctions[i].sanction_expiretime
            local reason = sanctions[i].sanction_reason

            if sanction_type == SANCTION_BAN then
                return player:Drop(DisconnectReason.KickBanAdded)
            elseif sanction_type == SANCTION_GAG then
                PerformGag(player, 0, expiretime == 0 and 0 or math.floor(((expiretime * 1000) - GetTime()) / 1000), reason, false)
                player:vars():Set("sanctions.gagid", id)
            elseif sanction_type == SANCTION_MUTE then
                PerformMute(player, 0, expiretime == 0 and 0 or math.floor(((expiretime * 1000) - GetTime()) / 1000), reason, false)
                player:vars():Set("sanctions.muteid", id)
            end
        end
    end
end

events:on("OnGameTick", function(simulating, bFirstTick, bLastTick)
    if db:IsConnected() == 0 then return end

    for steamid,player in next,playersToCheckForSanctions,nil do
        if player:IsAuthenticated() == 1 then
            CheckSanctions(player)
            playersToCheckForSanctions[steamid] = nil
        end
    end
end)

function PrintSanctions(player)
    if player:vars():Get("sanctions.isgagged") == 1 then
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.gagged"), config:Fetch("admins.prefix"), ComputeTime(player:vars():Get("sanctions.gag.expire_time")), player:vars():Get("sanctions.gag.reason")))
    end
    if player:vars():Get("sanctions.ismuted") == 1 then
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.muted"), config:Fetch("admins.prefix"), ComputeTime(player:vars():Get("sanctions.mute.expire_time")), player:vars():Get("sanctions.mute.reason")))
    end
end

events:on("OnPlayerSpawn", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFirstSpawn() == 1 then
        PrintSanctions(player)
    end
end)

function ReloadSanctions()
    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local player = GetPlayer(i)
        if not player then goto continue end
        if player:IsFakeClient() == 1 then goto continue end

        CheckSanctions(player)
        PrintSanctions(player)

        ::continue::
    end
end

function SanctionExpireCheck()
    if db:IsConnected() == 0 then return end

    for i=0,playermanager:GetPlayerCap()-1,1 do 
        local player = GetPlayer(i)
        if not player then goto continue end
        if player:IsFakeClient() == 1 then goto continue end

        CheckExpiredSanctions(player, true)

        ::continue::
    end
end

timers:create(1000, SanctionExpireCheck)

function CheckExpiredSanctions(player, sendmessage)
    if player:vars():Get("sanctions.isgagged") == 1 and (player:vars():Get("sanctions.gag.expire_time") - GetTime() <= 0) and player:vars():Get("sanctions.gag.expire_time") ~= 0 then
        player:vars():Set("sanctions.isgagged", false);
        player:vars():Set("sanctions.gag.expire_time", 0);
        player:vars():Set("sanctions.gag.reason", "");
        db:Query(string.format("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:vars():Get("sanctions.gagid")))
        player:vars():Set("sanctions.gagid", 0);

        if sendmessage then player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.gag_expired"), config:Fetch("admins.prefix"))) end
    end

    if player:vars():Get("sanctions.ismuted") == 1 and (player:vars():Get("sanctions.mute.expire_time") - GetTime() <= 0) and player:vars():Get("sanctions.mute.expire_time") ~= 0 then
        player:vars():Set("sanctions.ismuted", false);
        player:vars():Set("sanctions.mute.expire_time", 0);
        player:vars():Set("sanctions.mute.reason", "");
        db:Query(string.format("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:vars():Get("sanctions.muteid")))
        player:vars():Set("sanctions.muteid", 0);

        if sendmessage then player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.mute_expired"), config:Fetch("admins.prefix"))) end
    end
end

function PerformMute(player, admin_steamid, seconds, reason, query)
    if query then
        if db:IsConnected() == 1 then
            db:Query(string.format("update %s set sanction_expiretime = '%d' where sanction_player = '%.0f' and sanction_type = '%d' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0)",
                                    config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:GetSteamID(), SANCTION_MUTE))

            local result = db:Query(string.format("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%.0f', '%d', '%d', '%d', '%s', '%s')",
                                        config:Fetch("admins.table_name.sanctions"), player:GetSteamID(), SANCTION_MUTE, seconds == 0 and 0 or (math.floor(GetTime() / 1000) + seconds), seconds, reason, admin_steamid == 0 and "-1" or tostring(admin_steamid)))

            if #result > 0 then
                local insertID = result[1].insertId
                player:vars():Set("sanctions.muteid", insertID)
            end
        end
    end

    player:vars():Set("sanctions.ismuted", true);
    player:vars():Set("sanctions.mute.expire_time", seconds == 0 and 0 or (GetTime() + (seconds * 1000)));
    player:vars():Set("sanctions.mute.reason", reason);
end

function PerformGag(player, admin_steamid, seconds, reason, query)
    if query then 
        if db:IsConnected() == 1 then
            db:Query(string.format("update %s set sanction_expiretime = '%d' where sanction_player = '%.0f' and sanction_type = '%d' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0)",
                                    config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:GetSteamID(), SANCTION_GAG))

            local result = db:Query(string.format("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%.0f', '%d', '%d', '%d', '%s', '%s')",
                                        config:Fetch("admins.table_name.sanctions"), player:GetSteamID(), SANCTION_GAG, seconds == 0 and 0 or (math.floor(GetTime() / 1000) + seconds), seconds, reason, admin_steamid == 0 and "-1" or tostring(admin_steamid)))

            if #result > 0 then
                local insertID = result[1].insertId
                player:vars():Set("sanctions.gagid", insertID)
            end
        end
    end

    player:vars():Set("sanctions.isgagged", true)
    player:vars():Set("sanctions.gag.expire_time", seconds == 0 and 0 or (GetTime() + (seconds * 1000)))
    player:vars():Set("sanctions.gag.reason", reason)
end

function PerformUngag(player)
    player:vars():Set("sanctions.isgagged", false);
    player:vars():Set("sanctions.gag.expire_time", 0);
    player:vars():Set("sanctions.gag.reason", "");
    if player:vars():Get("sanctions.gagid") ~= 0 then
        db:Query(string.format("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:vars():Get("sanctions.gagid")))
        player:vars():Set("sanctions.gagid", 0);
    end
end

function PerformUnmute(player)
    player:vars():Set("sanctions.ismuted", false);
    player:vars():Set("sanctions.mute.expire_time", 0);
    player:vars():Set("sanctions.mute.reason", "");
    if player:vars():Get("sanctions.muteid") ~= 0 then
        db:Query(string.format("update %s set sanction_expiretime = '%d' where id = '%d' limit 1", config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), player:vars():Get("sanctions.muteid")))
        player:vars():Set("sanctions.muteid", 0);
    end
end

function PerformBan(player_steamid, admin_steamid, seconds, reason)
    if db:IsConnected() == 1 then
        db:Query(string.format("insert into %s (sanction_player, sanction_type, sanction_expiretime, sanction_length, sanction_reason, sanction_admin) values ('%.0f', '%d', '%d', '%d', '%s', '%s')",
                  config:Fetch("admins.table_name.sanctions"), player_steamid, SANCTION_BAN, seconds == 0 and 0 or math.floor((GetTime() / 1000) + seconds), seconds, reason, admin_steamid == 0 and "-1" or tostring(admin_steamid)))

        logger:Write(LogType.Common, string.format("'%s' banned '%s'. Time: %s | Reason: %s", admin_steamid == 0 and "CONSOLE" or tostring(admin_steamid), tostring(player_steamid), ComputeSanctionTime(seconds), reason));
    end
end

function PerformUnban(steamid, adminsteamid)
    if db:IsConnected() == 1 then
        db:Query(string.format("update %s set sanction_expiretime = '%d' where sanction_player = '%.0f' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0) and sanction_type = '%d'", config:Fetch("admins.table_name.sanctions"), math.floor(GetTime() / 1000), steamid, SANCTION_BAN)) 
        logger:Write(LogType.Common, string.format("'%s' unbanned '%s'.", adminsteamid == 0 and "CONSOLE" or tostring(adminsteamid), tostring(steamid)))
    end
end