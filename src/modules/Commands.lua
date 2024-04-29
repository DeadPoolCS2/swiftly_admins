function ComputeSanctionTime(seconds)
    if seconds == 0 then return FetchTranslation("admins.forever")
    elseif seconds < 60 then return string.format(FetchTranslation("admins.seconds"), seconds)
    elseif seconds < 3600 then return string.format(FetchTranslation("admins.minutes"), math.floor(seconds / 60))
    elseif seconds < 86400 then return string.format(FetchTranslation("admins.hours"), math.floor(seconds / 3600))
    else return string.format(FetchTranslation("admins.days"), math.floor(seconds / 86400)) end
end

function GetPrefix(silent)
    return config:Fetch(silent == true and "core.silentCommandPrefixes" or "core.commandPrefixes"):sub(1,1)
end

commands:Register("reloadadmins", function(playerid, args, argc, silent)
    if playerid == -1 then
        LoadAdmins()
        ReloadServerAdmins()

        print(string.format(FetchTranslation("admins.reloadadmins"), config:Fetch("admins.prefix")))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_ROOT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        LoadAdmins()
        ReloadServerAdmins()

        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.reloadadmins"), config:Fetch("admins.prefix")))
    end
end)

commands:Register("slay", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.slay.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        
        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        target:Kill()
        print(string.format(FetchTranslation("admins.player_slayed"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_slayed"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_SLAY) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slay.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
        
        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        target:Kill()
        print(string.format(FetchTranslation("admins.player_slayed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_slayed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("chat", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.slay.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        
        local message = table.concat(args, " ")
        local formatted_msg = string.format(FetchTranslation("admins.chat.admin_chat"), "CONSOLE", message)
        for i=0,playermanager:GetPlayerCap()-1,1 do 
            local admin = GetPlayer(i)
            if admin then
                if PlayerHasFlag(admin, ADMFLAG_CHAT) then
                    admin:SendMsg(MessageType.Chat, formatted_msg)
                end
            end
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.chat.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
        
        local message = table.concat(args, " ")
        local formatted_msg = string.format(FetchTranslation("admins.chat.admin_chat"), player:GetName(), message)
        for i=0,playermanager:GetPlayerCap()-1,1 do 
            local admin = GetPlayer(i)
            if admin then
                if PlayerHasFlag(admin, ADMFLAG_CHAT) then
                    admin:SendMsg(MessageType.Chat, formatted_msg)
                end
            end
        end
    end
end)

commands:Register("csay", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.csay.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        
        local message = table.concat(args, " ")
        playermanager:SendMsg(MessageType.Center, string.format("%s: %s", "CONSOLE", message))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.csay.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
        
        local message = table.concat(args, " ")
        playermanager:SendMsg(MessageType.Center, string.format("%s: %s", player:GetName(), message))
    end
end)

commands:Register("say", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.say.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        
        local message = table.concat(args, " ")
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.say.message"), "CONSOLE", message))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.say.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
        
        local message = table.concat(args, " ")
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.say.message"), player:GetName(), message))
    end
end)

commands:Register("psay", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.psay.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        
        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        table.remove(args, 1)
        local message = table.concat(args, " ")
        target:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.psay.message"), "CONSOLE", message))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.psay.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
        
        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        table.remove(args, 1)
        local message = table.concat(args, " ")
        target:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.psay.message"), player:GetName(), message))
    end
end)

commands:Register("rcon", function(playerid, args, argc, silent)
    if playerid == -1 then return end

    local player = GetPlayer(playerid)
    if not player then return end

    if not PlayerHasFlag(player, ADMFLAG_RCON) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
    if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rcon.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

    local cmd = table.concat(args, " ")
    if cmd:find("sw ") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

    server:ExecuteCommand(cmd)
end)

local ChangeMap = function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.changemap.syntax"), config:Fetch("admins.prefix"), "sw_")) end
        local map = args[1]
        if server:IsMapValid(map) == 0 then return print(string.format(FetchTranslation("admins.invalid_map"), config:Fetch("admins.prefix"), map)) end
        print(string.format(FetchTranslation("admins.changing_map"), config:Fetch("admins.prefix"), map))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.changing_map"), config:Fetch("admins.prefix"), map))

        SetTimeout(3000, function()
            server:ChangeLevel(map)
        end)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHANGEMAP) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.changemap.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local map = args[1]
        if server:IsMapValid(map) == 0 then return print(string.format(FetchTranslation("admins.invalid_map"), config:Fetch("admins.prefix"), map)) end
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.changing_map"), config:Fetch("admins.prefix"), map))

        SetTimeout(3000, function()
            server:ChangeLevel(map)
        end)
    end
end

commands:Register("map", ChangeMap)
commands:Register("changemap", ChangeMap)

commands:Register("kick", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.kick.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.kick.message"), "CONSOLE", target:GetName(), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.kick.message"), "CONSOLE", target:GetName(), reason))
        target:Drop(DisconnectReason.Kicked)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.kick.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.kick.message"), player:GetName(), target:GetName(), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.kick.message"), player:GetName(), target:GetName(), reason))
        target:Drop(DisconnectReason.Kicked)
    end
end)

commands:Register("mute", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 3 then return print(string.format(FetchTranslation("admins.mute.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.ismuted") == 1 then return print(string.format(FetchTranslation("admins.player_already_muted"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return print(string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.mute.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.mute.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformMute(target, 0, time * 60, reason, true)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 3 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.mute.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.ismuted") == 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_already_muted"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.mute.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.mute.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformMute(target, player:GetSteamID(), time * 60, reason, true)
    end
end)

commands:Register("gag", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 3 then return print(string.format(FetchTranslation("admins.gag.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.isgagged") == 1 then return print(string.format(FetchTranslation("admins.player_already_gagged"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return print(string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.gag.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.gag.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformGag(target, 0, time * 60, reason, true)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 3 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.gag.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.isgagged") == 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_already_gagged"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.gag.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.gag.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformGag(target, player:GetSteamID(), time * 60, reason, true)
    end
end)

commands:Register("silence", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 3 then return print(string.format(FetchTranslation("admins.silence.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.isgagged") == 1 or target:vars():Get("sanctions.ismuted") == 1 then return print(string.format(FetchTranslation("admins.player_already_gagged_or_muted"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return print(string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.silence.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.silence.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformGag(target, 0, time * 60, reason, true)
        PerformMute(target, 0, time * 60, reason, true)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 3 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.silence.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.isgagged") == 1 or target:vars():Get("sanctions.ismuted") == 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_already_gagged_or_muted"), config:Fetch("admins.prefix"), target:GetName())) end

        local time = tonumber(args[2])
        if time < 0 or time > 1440 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 1440)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.silence.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.silence.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformGag(target, player:GetSteamID(), time * 60, reason, true)
        PerformMute(target, player:GetSteamID(), time * 60, reason, true)
    end
end)

commands:Register("unmute", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.unmute.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.ismuted") == 0 then return print(string.format(FetchTranslation("admins.player_not_muted"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.unmute.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unmute.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))

        PerformUnmute(target)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unmute.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.ismuted") == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_muted"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.unmute.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unmute.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        PerformUnmute(target)
    end
end)

commands:Register("ungag", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.ungag.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.isgagged") == 0 then return print(string.format(FetchTranslation("admins.player_not_gagged"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.ungag.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ungag.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))

        PerformUngag(target)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ungag.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.isgagged") == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_gagged"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.ungag.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ungag.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        PerformUngag(target)
    end
end)

commands:Register("unsilence", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.unsilence.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("sanctions.isgagged") == 0 or target:vars():Get("sanctions.ismuted") == 0 then return print(string.format(FetchTranslation("admins.player_not_gagged_and_muted"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.ununsilenceag.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unsilence.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))

        PerformUngag(target)
        PerformUnmute(target)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unsilence.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        if target:vars():Get("sanctions.isgagged") == 0 or target:vars():Get("sanctions.ismuted") == 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_gagged_and_muted"), config:Fetch("admins.prefix"), target:GetName())) end
    
        print(string.format(FetchTranslation("admins.unsilence.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unsilence.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        PerformUngag(target)
        PerformUnmute(target)
    end
end)

commands:Register("slap", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.slap.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local vel = target:velocity():Get()
        vel.x = vel.x + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
        vel.y = vel.y + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
        vel.z = vel.z + math.random(100, 300)

        target:velocity():Set(vel)

        if argc > 1 then
            damage = tonumber(args[2])
            target:health():Set(target:health():Get() - damage)
            if target:health():Get() <= 0 then
                target:Kill()
            end
            if damage < 0 then return print(string.format(FetchTranslation("admins.invalid_damage"), config:Fetch("admins.prefix"))) end
        end
        
        if damage ~= nil then
            print(string.format(FetchTranslation("admins.slap.message_with_damage"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), damage))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message_with_damage"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), damage))
        else
            print(string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_SLAY) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local vel = target:velocity():Get()
        vel.x = vel.x + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
        vel.y = vel.y + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
        vel.z = vel.z + math.random(100, 300)

        target:velocity():Set(vel)

        if argc > 1 then
            damage = tonumber(args[2])
            target:health():Set(target:health():Get() - damage)
            if target:health():Get() <= 0 then
                target:Kill()
            end
            if damage < 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_damage"), config:Fetch("admins.prefix"))) end
        end
        
        if damage ~= nil then
            print(string.format(FetchTranslation("admins.slap.message_with_damage"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), damage))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message_with_damage"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), damage))
        else
            print(string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        end
    end
end)

commands:Register("ban", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 3 then return print(string.format(FetchTranslation("admins.ban.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local time = tonumber(args[2])
        if time < 0 or time > 365 then return print(string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 365)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.ban.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ban.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformBan(target:GetSteamID(), 0, time * 86400, reason)
        target:Drop(DisconnectReason.KickBanAdded)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 3 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ban.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local time = tonumber(args[2])
        if time < 0 or time > 365 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_time"), config:Fetch("admins.prefix"), 1, 365)) end

        table.remove(args, 1)
        table.remove(args, 1)
        local reason = table.concat(args, " ")

        print(string.format(FetchTranslation("admins.ban.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.ban.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), ComputeSanctionTime(time * 60), reason))

        PerformBan(target:GetSteamID(), player:GetSteamID(), time * 86400, reason)
        target:Drop(DisconnectReason.KickBanAdded)
    end
end)

commands:Register("unban", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.unban.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetsteamid = math.floor(tonumber(args[1]) + 0.0)
        print(string.format(FetchTranslation("admins.unban.message"), config:Fetch("admins.prefix"), "CONSOLE", targetsteamid))

        PerformUnban(targetsteamid, 0)
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_UNBAN) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unban.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetsteamid = math.floor(tonumber(args[1]) + 0.0)
        print(string.format(FetchTranslation("admins.unban.message"), config:Fetch("admins.prefix"), player:GetName(), targetsteamid))
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unban.message"), config:Fetch("admins.prefix"), player:GetName(), targetsteamid))
        PerformUnban(targetsteamid, player:GetSteamID())
    end
end)

commands:Register("addadmin", function(playerid, args, argc, silent)
    if playerid ~= -1 then return end
    if argc < 3 then return print(string.format(FetchTranslation("admins.addadmin.syntax"), config:Fetch("admins.prefix"), "sw_")) end

    local steamid = args[1]
    local flags = args[2]
    local immunity = tonumber(args[3])

    if immunity < 0 then return print(string.format(FetchTranslation("admins.invalid_immunity"), config:Fetch("admins.prefix"))) end
    if not HasValidFlags(flags) then return print(string.format(FetchTranslation("admins.invalid_flags"), config:Fetch("admins.prefix"))) end
    if admins[steamid] then return print(string.format(FetchTranslation("admins.already_has_admin"), config:Fetch("admins.prefix"), steamid)) end

    db:Query(string.format("insert into %s (steamid, flags, immunity) values ('%s', '%s', '%d')", config:Fetch("admins.table_name.admins"), steamid, flags, immunity))
    ReloadServerAdmins()
    print(string.format(FetchTranslation("admins.addadmin.message"), config:Fetch("admins.prefix"), "CONSOLE", steamid, flags, immunity))
end)

commands:Register("removeadmin", function(playerid, args, argc, silent)
    if playerid ~= -1 then return end
    if argc < 1 then return print(string.format(FetchTranslation("admins.removeadmin.syntax"), config:Fetch("admins.prefix"), "sw_")) end

    local steamid = args[1]
    if not admins[steamid] then return print(string.format(FetchTranslation("admins.is_not_an_admin"), config:Fetch("admins.prefix"), steamid)) end

    db:Query(string.format("delete from %s where steamid = '%s' limit 1", config:Fetch("admins.table_name.admins"), steamid))
    ReloadServerAdmins()
    print(string.format(FetchTranslation("admins.removeadmin.message"), config:Fetch("admins.prefix"), "CONSOLE", steamid))
end)

commands:Register("rr", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc > 1 then return print(string.format(FetchTranslation("admins.rr.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local time = tonumber(args[1])
        if time == nil then time = 1 end
        if time == 0 then
            if restart_round then
                print(string.format(FetchTranslation("admins.rr.cancel"), config:Fetch("admins.prefix"), "CONSOLE"))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.cancel"), config:Fetch("admins.prefix"), "CONSOLE"))
                restart_round = false
            else
                print(string.format(FetchTranslation("admins.rr.no_restart"), config:Fetch("admins.prefix"), "CONSOLE"))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.no_restart"), config:Fetch("admins.prefix"), "CONSOLE"))
            end
        else
            print(string.format(FetchTranslation("admins.rr.message"), config:Fetch("admins.prefix"), "CONSOLE", time))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.message"), config:Fetch("admins.prefix"), "CONSOLE", time))
            restart_round = true
            SetTimeout(time * 1000, function()
                if restart_round then
                    server:ExecuteCommand("sv_cheats 1; endround; sv_cheats 0;") -- Lazy way, but works.
                    restart_round = false
                end
            end)
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc > 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local time = tonumber(args[1])
        if time == nil then time = 1 end
        if time == 0 then
            if restart_round then
                print(string.format(FetchTranslation("admins.rr.cancel"), config:Fetch("admins.prefix"), player:GetName()))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.cancel"), config:Fetch("admins.prefix"), player:GetName()))
                restart_round = false
            else
                print(string.format(FetchTranslation("admins.rr.no_restart"), config:Fetch("admins.prefix"), player:GetName()))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.no_restart"), config:Fetch("admins.prefix"), player:GetName()))
            end
        else
            print(string.format(FetchTranslation("admins.rr.message"), config:Fetch("admins.prefix"), player:GetName(), time))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rr.message"), config:Fetch("admins.prefix"), player:GetName(), time))
            restart_round = true
            SetTimeout(time * 1000, function()
                if restart_round then
                    server:ExecuteCommand("sv_cheats 1; endround; sv_cheats 0;") -- Lazy way, but works.
                    restart_round = false
                end
            end)
        end
    end
end)

commands:Register("rg", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc > 1 then return print(string.format(FetchTranslation("admins.rg.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local time = tonumber(args[1])
        if time == nil then time = 1 end
        if time == 0 then
            if restart_game then
                print(string.format(FetchTranslation("admins.rg.cancel"), config:Fetch("admins.prefix"), "CONSOLE"))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.cancel"), config:Fetch("admins.prefix"), "CONSOLE"))
                restart_game = false
            else
                print(string.format(FetchTranslation("admins.rg.no_restart"), config:Fetch("admins.prefix"), "CONSOLE"))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.no_restart"), config:Fetch("admins.prefix"), "CONSOLE"))
            end
        else
            print(string.format(FetchTranslation("admins.rg.message"), config:Fetch("admins.prefix"), "CONSOLE", time))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.message"), config:Fetch("admins.prefix"), "CONSOLE", time))
            restart_game = true
            SetTimeout(time * 1000, function()
                if restart_game then
                    server:ExecuteCommand("mp_restartgame 1")
                    restart_game = false
                end
            end)
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc > 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local time = tonumber(args[1])
        if time == nil then time = 1 end
        if time == 0 then
            if restart_game then
                print(string.format(FetchTranslation("admins.rg.cancel"), config:Fetch("admins.prefix"), player:GetName()))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.cancel"), config:Fetch("admins.prefix"), player:GetName()))
                restart_game = false
            else
                print(string.format(FetchTranslation("admins.rg.no_restart"), config:Fetch("admins.prefix"), player:GetName()))
                playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.no_restart"), config:Fetch("admins.prefix"), player:GetName()))
            end
        else
            print(string.format(FetchTranslation("admins.rg.message"), config:Fetch("admins.prefix"), player:GetName(), time))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rg.message"), config:Fetch("admins.prefix"), player:GetName(), time))
            restart_game = true
            SetTimeout(time * 1000, function()
                if restart_game then
                    server:ExecuteCommand("mp_restartgame 1")
                    restart_game = false
                end
            end)
        end
    end
end)

commands:Register("hp", function(playerid, args, argc, silent) -- !hp <#userid|name|steamid|targetid> [health] [armor (optional)] [helmet=1/0 (optional)] => WIP 90% done.
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.hp.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end
        
        if argc == 2 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return print(string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)
            print(string.format(FetchTranslation("admins.hp.message1"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message1"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health))
        elseif argc == 3 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return print(string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)

            local armor = tonumber(args[3])
            if armor < 0 or armor > 999 then return print(string.format(FetchTranslation("admins.hp.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end
            target:armor():Set(armor)

            print(string.format(FetchTranslation("admins.hp.message2"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health, armor))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message2"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health, armor))
        elseif argc == 4 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return print(string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)

            local armor = tonumber(args[3])
            if armor < 0 or armor > 999 then return print(string.format(FetchTranslation("admins.hp.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end

            local helmet = tonumber(args[4])
            if helmet < 0 or helmet > 1 then return print(string.format(FetchTranslation("admins.hp.invalid_helmet"), config:Fetch("admins.prefix"), 0, 1)) end

            if helmet == 1 then target:weapons():GiveWeapons("item_assaultsuit") 
            elseif helmet == 0 then target:armor():Set("0") end
            target:armor():Set(armor)
            print(string.format(FetchTranslation("admins.hp.message3"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health, armor, helmet))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message3"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), health, armor, helmet))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_SLAY) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end
       
        -- currently argc > 3 to disable helmet feature, set to argc == 4 to enable helmet feature
        if argc > 3 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        if argc == 2 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)
            print(string.format(FetchTranslation("admins.hp.message1"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message1"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health))
        elseif argc == 3 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)

            local armor = tonumber(args[3])
            if armor < 0 or armor > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end
            target:armor():Set(armor)

            print(string.format(FetchTranslation("admins.hp.message2"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health, armor))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message2"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health, armor))
        elseif argc == 4 then
            local health = tonumber(args[2])
            if health < 0 or health > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.invalid_health"), config:Fetch("admins.prefix"), 0, 999)) end
            target:health():Set(health)

            local armor = tonumber(args[3])
            if armor < 0 or armor > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end

            local helmet = tonumber(args[4])
            if helmet < 0 or helmet > 1 then return print(string.format(FetchTranslation("admins.hp.invalid_helmet"), config:Fetch("admins.prefix"), 0, 1)) end

            if helmet == 1 then target:weapons():GiveWeapons("item_assaultsuit") 
            elseif helmet == 0 then
                -- TODO: Remove helmet feature
            end
            target:armor():Set(armor)
            print(string.format(FetchTranslation("admins.hp.message3"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health, armor, helmet))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.hp.message3"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), health, armor, helmet))
        end
    end
end)

commands:Register("team", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.team.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local team = args[2]
        if team ~= "ct" and team ~= "t" and team ~= "spec" then return print(string.format(FetchTranslation("admins.team.invalid_team"), config:Fetch("admins.prefix"))) end

        if team == "ct" then
            target:team():Set(TEAM_CT)
            target:Respawn()
        elseif team == "t" then
            target:team():Set(TEAM_T)
            target:Respawn()
        elseif team == "spec" then
            target:team():Set(TEAM_SPEC)
            target:Respawn()
        end

        print(string.format(FetchTranslation("admins.team.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), team))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.team.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), team))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.team.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local team = args[2]
        if team ~= "ct" and team ~= "t" and team ~= "spec" then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.team.invalid_team"), config:Fetch("admins.prefix"))) end

        if team == "ct" then
            target:team():Set(TEAM_CT)
            target:Respawn()
        elseif team == "t" then
            target:team():Set(TEAM_T)
            target:Respawn()
        elseif team == "spec" then
            target:team():Set(TEAM_SPEC)
            target:Respawn()
        end

        print(string.format(FetchTranslation("admins.team.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), team))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.team.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), team))
    end
end)

commands:Register("swap", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.swap.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:team():Get() == TEAM_CT then
            target:team():Set(TEAM_T)
            target:Respawn()
        elseif target:team():Get() == TEAM_T then
            target:team():Set(TEAM_CT)
            target:Respawn()
        end

        print(string.format(FetchTranslation("admins.swap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.swap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.swap.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        if target:team():Get() == TEAM_CT then
            target:team():Set(TEAM_T)
            target:Respawn()
        elseif target:team():Get() == TEAM_T then
            target:team():Set(TEAM_CT)
            target:Respawn()
        end

        print(string.format(FetchTranslation("admins.swap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.swap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("respawn", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.respawn.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        target:Respawn()
        print(string.format(FetchTranslation("admins.respawn.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.respawn.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.respawn.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        target:Respawn()
        print(string.format(FetchTranslation("admins.respawn.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.respawn.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("cc", function(playerid, args, argc, silent)
    if playerid == -1 then
        for i = 1, 20 do
            playermanager:SendMsg(MessageType.Chat, " \x01\x0B \x0B ")
        end
        print(string.format(FetchTranslation("admins.cc.message"), config:Fetch("admins.prefix"), "CONSOLE"))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cc.message"), config:Fetch("admins.prefix"), "CONSOLE"))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_CHAT) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        for i = 1, 20 do
            playermanager:SendMsg(MessageType.Chat, " \x01\x0B \x0B ", player)
        end
        print(string.format(FetchTranslation("admins.cc.message"), config:Fetch("admins.prefix"), player:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cc.message"), config:Fetch("admins.prefix"), player:GetName()))
    end
end)

commands:Register("give", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.give.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local weapon = args[2]
        if not IsValidWeapon("weapon_" .. weapon) then return print(string.format(FetchTranslation("admins.give.invalid_weapon"), config:Fetch("admins.prefix"))) end

        target:weapons():GiveWeapons("weapon_" .. weapon)
        print(string.format(FetchTranslation("admins.give.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), weapon))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.give.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), weapon))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.give.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local weapon = args[2]
        if not IsValidWeapon("weapon_" .. weapon) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.give.invalid_weapon"), config:Fetch("admins.prefix"))) end

        target:weapons():GiveWeapons("weapon_" .. weapon)
        print(string.format(FetchTranslation("admins.give.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), weapon))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.give.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), weapon))
    end
end)

commands:Register("giveitem", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.giveitem.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local item = args[2]
        if not IsValidItem("item_" .. item) then return print(string.format(FetchTranslation("admins.giveitem.invalid_item"), config:Fetch("admins.prefix"))) end

        target:weapons():GiveWeapons("item_" .. item)
        print(string.format(FetchTranslation("admins.giveitem.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), item))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.giveitem.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), item))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.giveitem.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local item = args[2]
        if not IsValidItem("item_" .. item) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.giveitem.invalid_item"), config:Fetch("admins.prefix"))) end

        target:weapons():GiveWeapons("item_" .. item)
        print(string.format(FetchTranslation("admins.giveitem.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), item))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.giveitem.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), item))
    end
end)

commands:Register("melee", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.melee.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        target:weapons():RemoveWeapons()
        print(string.format(FetchTranslation("admins.melee.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.melee.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.melee.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        target:weapons():RemoveWeapons()
        print(string.format(FetchTranslation("admins.melee.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.melee.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("disarm", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.disarm.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        target:weapons():RemoveWeapons()
        print(string.format(FetchTranslation("admins.disarm.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.disarm.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.disarm.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        target:weapons():RemoveWeapons()
        local currentweapon = player:weapons():GetWeaponFromSlot(WeaponSlot.CurrentWeapon)
        if currentweapon then
            currentweapon:Remove()
        end
        print(string.format(FetchTranslation("admins.disarm.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.disarm.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("xyz", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc > 1 then return print(string.format(FetchTranslation("admins.xyz.syntax.server"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = target:coords():Get()
        print(string.format(FetchTranslation("admins.xyz.message.server"), config:Fetch("admins.prefix"), target:GetName(), position.x, position.y, position.z))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc > 0 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.xyz.syntax.client"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local position = player:coords():Get()
        player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.xyz.message.client"), config:Fetch("admins.prefix"), position.x, position.y, position.z))
    end
end)

commands:Register("god", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.god.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("godmode") == 1 then
            target:vars():Set("godmode", 0)
            print(string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
        else
            target:vars():Set("godmode", 1)
            print(string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.god.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("godmode") == 1 then
            target:vars():Set("godmode", 0)
            print(string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
        else
            target:vars():Set("godmode", 1)
            print(string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.god.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
        end
    end
end)

commands:Register("armor", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.armor.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local armor = tonumber(args[2])
        if armor < 0 or armor > 999 then return print(string.format(FetchTranslation("admins.armor.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end

        target:armor():Set(armor)
        print(string.format(FetchTranslation("admins.armor.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), armor))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.armor.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), armor))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.armor.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local armor = tonumber(args[2])
        if armor < 0 or armor > 999 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.armor.invalid_armor"), config:Fetch("admins.prefix"), 0, 999)) end

        target:armor():Set(armor)
        print(string.format(FetchTranslation("admins.armor.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), armor))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.armor.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), armor))
    end
end)

commands:Register("1up", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.1up.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = target:vars():Get("deathposition")
        if position == "nil" then return print(string.format(FetchTranslation("admins.1up.no_death_position"), config:Fetch("admins.prefix"), target:GetName())) end

        target:Respawn()

        NextTick(function()
            target:coords():Set(toVector3(position))
        end)

        print(string.format(FetchTranslation("admins.1up.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.1up.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.1up.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = target:vars():Get("deathposition")
        if position == "nil" then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.1up.no_death_position"), config:Fetch("admins.prefix"), target:GetName())) end

        target:Respawn()

        NextTick(function()
            target:coords():Set(toVector3(position))
        end)
        
        print(string.format(FetchTranslation("admins.1up.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.1up.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("tele", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 2 then return print(string.format(FetchTranslation("admins.tele.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid_A = GetPlayerId(args[1])
        if targetid_A == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local targetid_B = GetPlayerId(args[2])
        if targetid_B == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target_A = GetPlayer(targetid_A)
        if not target_A then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local target_B = GetPlayer(targetid_B)
        if not target_B then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[2])) end

        local position = target_B:coords():Get()
        
        target_A:coords():Set(position + vector3(0, 0, 100))

        print(string.format(FetchTranslation("admins.tele.message"), config:Fetch("admins.prefix"), "CONSOLE", target_A:GetName(), target_B:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.tele.message"), config:Fetch("admins.prefix"), "CONSOLE", target_A:GetName(), target_B:GetName()))
    else
        player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.tele.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid_A = GetPlayerId(args[1])
        if targetid_A == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local targetid_B = GetPlayerId(args[2])
        if targetid_B == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target_A = GetPlayer(targetid_A)
        if not target_A then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local target_B = GetPlayer(targetid_B)
        if not target_B then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[2])) end

        if target_A:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") or target_B:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = target_B:coords():Get()
        
        target_A:coords():Set(position + vector3(0, 0, 100))

        print(string.format(FetchTranslation("admins.tele.message"), config:Fetch("admins.prefix"), player:GetName(), target_A:GetName(), target_B:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.tele.message"), config:Fetch("admins.prefix"), player:GetName(), target_A:GetName(), target_B:GetName()))
    end
end)

commands:Register("bring", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.bring.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = GetPlayer(playerid):coords():Get()
        
        target:coords():Set(position + vector3(0, 0, 300))

        print(string.format(FetchTranslation("admins.bring.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bring.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bring.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = player:coords():Get()
        
        target:coords():Set(position + vector3(0, 0, 300))

        print(string.format(FetchTranslation("admins.bring.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bring.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("goto", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.goto.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = target:coords():Get()
        
        GetPlayer(playerid):coords():Set(position + vector3(0, 0, 100))

        print(string.format(FetchTranslation("admins.goto.message"), config:Fetch("admins.prefix"), "CONSOLE", GetPlayer(playerid):GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.goto.message"), config:Fetch("admins.prefix"), "CONSOLE", GetPlayer(playerid):GetName(), target:GetName()))
    else
        player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.goto.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = target:coords():Get()

        player:coords():Set(position + vector3(0, 0, 100))

        print(string.format(FetchTranslation("admins.goto.message"), config:Fetch("admins.prefix"), player:GetName(), GetPlayer(playerid):GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.goto.message"), config:Fetch("admins.prefix"), player:GetName(), GetPlayer(playerid):GetName(), target:GetName()))
    end
end)

commands:Register("noclip", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.noclip.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("noclip") == 1 then
            target:vars():Set("noclip", 0)
            target:SetActualMoveType(MoveType_t.MOVETYPE_WALK)
            local entity = entities:Create("player:" .. targetid)
            entity:SetCollisionGroup(CollisionGroup.Default)
            print(string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
        else
            target:vars():Set("noclip", 1)
            target:SetActualMoveType(MoveType_t.MOVETYPE_NOCLIP)
            local entity = entities:Create("player:" .. targetid)
            entity:SetCollisionGroup(CollisionGroup.In_Vehicle)
            print(string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.noclip.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        if target:vars():Get("noclip") == 1 then
            target:vars():Set("noclip", 0)
            target:SetActualMoveType(MoveType_t.MOVETYPE_WALK)
            local entity = entities:Create("player:" .. targetid)
            entity:SetCollisionGroup(CollisionGroup.Default)
            print(string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
        else
            target:vars():Set("noclip", 1)
            target:SetActualMoveType(MoveType_t.MOVETYPE_NOCLIP)
            local entity = entities:Create("player:" .. targetid)
            entity:SetCollisionGroup(CollisionGroup.In_Vehicle)
            print(string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.noclip.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
        end
    end
end)

commands:Register("freeze", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.freeze.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("freeze") == 1 then
            target:vars():Set("freeze", 0)
            target:SetActualMoveType(MoveType_t.MOVETYPE_WALK)
            print(string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
        else
            target:vars():Set("freeze", 1)
            target:SetActualMoveType(MoveType_t.MOVETYPE_NONE)
            print(string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.enabled")))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.freeze.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        if target:vars():Get("freeze") == 1 then
            print(string.format(FetchTranslation("admins.player_already_freezed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_already_freezed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        else
            target:vars():Set("freeze", 1)
            target:SetActualMoveType(MoveType_t.MOVETYPE_NONE)
            print(string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.enabled")))
        end
    end
end) 

commands:Register("unfreeze", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.unfreeze.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("freeze") == 0 then
            print(string.format(FetchTranslation("admins.player_not_freezed"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_freezed"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        else
            target:vars():Set("freeze", 0)
            target:SetActualMoveType(MoveType_t.MOVETYPE_WALK)
            print(string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.freeze.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), FetchTranslation("admins.disabled")))
        end
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unfreeze.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        if target:vars():Get("freeze") == 0 then
            print(string.format(FetchTranslation("admins.player_not_freezed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_freezed"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        else
            target:vars():Set("freeze", 0)
            target:SetActualMoveType(MoveType_t.MOVETYPE_WALK)
            print(string.format(FetchTranslation("admins.unfreeze.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
            playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unfreeze.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), FetchTranslation("admins.disabled")))
        end
    end
end)

commands:Register("bury", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.bury.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = target:coords():Get()
        
        target:coords():Set(position + vector3(0, 0, -30))

        print(string.format(FetchTranslation("admins.bury.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bury.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bury.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = target:coords():Get()
        
        target:coords():Set(position + vector3(0, 0, -30))

        print(string.format(FetchTranslation("admins.bury.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.bury.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("unbury", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.unbury.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        local position = target:coords():Get()
        
        target:coords():Set(position + vector3(0, 0, 10))

        print(string.format(FetchTranslation("admins.unbury.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unbury.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
    else
        player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end

        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unbury.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local position = target:coords():Get()
        
        target:coords():Set(position + vector3(0, 0, 10))

        print(string.format(FetchTranslation("admins.unbury.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.unbury.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
    end
end)

commands:Register("uslap", function(playerid, args, argc, silent)
    if playerid == -1 then
        if argc < 1 then return print(string.format(FetchTranslation("admins.uslap.syntax"), config:Fetch("admins.prefix"), "sw_")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return print(string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return print(string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end

        -- if times not specified then slap 15 times
        if argc == 1 then args[2] = "15" end

        local times = tonumber(args[2])
        if times < 1 or times > 100 then return print(string.format(FetchTranslation("admins.uslap.invalid_times"), config:Fetch("admins.prefix"), 1, 100)) end

        local damage = 0
        if argc > 2 then
            damage = tonumber(args[3])
            if damage < 0 or damage > 1000 then return print(string.format(FetchTranslation("admins.uslap.invalid_damage"), config:Fetch("admins.prefix"), 0, 1000)) end
        end

        for i = 1, times do
            SetTimeout(i * 250, function()

                local vel = target:velocity():Get()
                vel.x = vel.x + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
                vel.y = vel.y + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
                vel.z = vel.z + math.random(100, 300)
        
                target:velocity():Set(vel)

                target:health():Set(target:health():Get() - damage)
                if target:health():Get() <= 0 then
                    target:Kill()
                end
            end)
        end

        print(string.format(FetchTranslation("admins.uslap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), times, damage))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.uslap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName(), times, damage))
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.uslap.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent))) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end
        
        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end
        
        -- if times not specified then slap 15 times
        if argc == 1 then args[2] = "15" end

        local times = tonumber(args[2])
        if times < 1 or times > 100 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.uslap.invalid_times"), config:Fetch("admins.prefix"), 1, 100)) end

        local damage = 0
        if argc > 2 then
            damage = tonumber(args[3])
            if damage < 0 or damage > 1000 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.uslap.invalid_damage"), config:Fetch("admins.prefix"), 0, 1000)) end
        end

        for i = 1, times do
            SetTimeout(i * 250, function()

                local vel = target:velocity():Get()
                vel.x = vel.x + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
                vel.y = vel.y + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
                vel.z = vel.z + math.random(100, 300)
        
                target:velocity():Set(vel)

                target:health():Set(target:health():Get() - damage)
                if target:health():Get() <= 0 then
                    target:Kill()
                end
            end)
        end

        print(string.format(FetchTranslation("admins.uslap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), times, damage))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.uslap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName(), times, damage))
    end
end)

--[[
commands:Register("rename", function(playerid, args, argc, silent) -- wip
    if playerid == -1 then
        -- server logic
    else
        local player = GetPlayer(playerid)
        if not player then return end

        if not PlayerHasFlag(player, ADMFLAG_KICK) then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.no_access"), config:Fetch("admins.prefix"))) end
        if argc < 2 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rename.syntax"), config:Fetch("admins.prefix"), GetPrefix(silent), "NewName")) end

        local targetid = GetPlayerId(args[1])
        if targetid == -1 then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.invalid_player"), config:Fetch("admins.prefix"))) end

        local target = GetPlayer(targetid)
        if not target then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.player_not_connected"), config:Fetch("admins.prefix"), args[1])) end
        
        if target:vars():Get("admin.immunity") > player:vars():Get("admin.immunity") then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.cannot_use_command"), config:Fetch("admins.prefix"))) end

        local name = args[2]
        if name == target:GetName() then return player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rename.same_name"), config:Fetch("admins.prefix"), target:GetName())) end

        target:SetName("1") -- remove previous name
        target:SetName(name)

        print(string.format(FetchTranslation("admins.rename.message"), config:Fetch("admins.prefix"), player:GetName(), args[1], name))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.rename.message"), config:Fetch("admins.prefix"), player:GetName(), args[1], name))
    end
end)
]]