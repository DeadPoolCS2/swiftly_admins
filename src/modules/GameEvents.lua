events:on("OnClientConnect", function(playerid)
   	local player = GetPlayer(playerid)
    if not player then return false end
        
    LoadAdmin(player)
    playersToCheckForSanctions[player:GetSteamID()] = player
end)

events:on("OnClientDisconnect", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end
        
    player:vars():Set("admin.flags" , 0)
    player:vars():Set("admin.immunity" , 0)
end)

events:on("OnPlayerChat", function(playerid, text, teamonly)
	local player = GetPlayer(playerid)
    if not player then return false end
        
   	if teamonly and text:sub(1,1) == "@" then
    	local sendText = text:sub(2)
        if player:vars():Get("admin.flags") == 0 then
           	player:SendMsg(MessageType.Chat, string.format(FetchTranslation("admins.chat.to_admins"), player:GetName(), sendText))    
        end
            
        local tosendmsg = string.format(FetchTranslation("admins.chat.admin_chat"), player:GetName(), sendText)
        for i=1,playermanager:GetPlayerCap() do 
            local player = GetPlayer(i)
            if not player then goto continue end
            if player:IsFakeClient() == 1 then goto continue end
            if not HasFlag(player:vars():Get("admin.flags"), ADMFLAG_CHAT) then goto continue end
            
           	player:SendMsg(MessageType.Chat, tosendmsg)
            
            ::continue::
        end
            
        return false
    end
        
    if player:vars():Get("sanctions.isgagged") == 1 then return false end
    return true
end)

events:on("ShouldHearVoice", function(playerid)
	local player = GetPlayer(playerid)
    if not player then return end
    
    return (player:vars():Get("sanctions.ismuted") == 0)
end)

events:on("OnPlayerDamage", function(playerid, damage, damagetype, bullettype, damageflags)
    local player = GetPlayer(playerid)
    if not player then return end

    if player:vars():Get("godmode") == 1 then
        return false
    end
end)

events:on("OnPlayerSpawn", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end

    if player:vars():Get("godmode") == 1 then
        player:vars():Set("godmode", 0)
    end

    if player:vars():Get("noclip") == 1 then
        player:vars():Set("noclip", 0)
    end

    if player:vars():Get("freeze") == 1 then
        player:vars():Set("freeze", 0)
    end
end)

events:on("OnPlayerDeath", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return end

    local position = player:coords():Get()
    player:vars():Set("deathposition", tostring(position))
end)