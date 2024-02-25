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

        target:coords():Set(target:coords():Get() + vector3(0.0, 0.0, 25.0))
        print(string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), "CONSOLE", target:GetName()))
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

        target:coords():Set(target:coords():Get() + vector3(0.0, 0.0, 25.0))
        print(string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
        playermanager:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.slap.message"), config:Fetch("admins.prefix"), player:GetName(), target:GetName()))
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
