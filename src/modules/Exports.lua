export("HasFlags", function(playerid, flags)
	local player = GetPlayer(playerid)
    if not player then return false end
	for i=1,string.len(flags) do 
        local flagPerm = flagsPermissions[flags:sub(i,i)]
        if not PlayerHasFlag(player, flagPerm) then return false end
    end
    return true
end)

export("IsMuted", function(playerid)
	local player = GetPlayer(playerid)
    if not player then return false end
    return (player:vars():Get("sanctions.ismuted") == 1)
end)

export("IsGagged", function(playerid)
	local player = GetPlayer(playerid)
    if not player then return false end
    return (player:vars():Get("sanctions.isgagged") == 1)
end)

export("IsSilenced", function(playerid)
	local player = GetPlayer(playerid)
    if not player then return false end
    return (player:vars():Get("sanctions.ismuted") == 1 and player:vars():Get("sanctions.isgagged") == 1)
end)

export("GetImmunity", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return 0 end
    return player:vars():Get("admin.immunity")
end)

export("IsBanned", function(steamid)
	local sanctions = db:Query(string.format("select * from %s where sanction_player = '%s' and sanction_type = '%d' and (sanction_expiretime = 0 OR sanction_expiretime - UNIX_TIMESTAMP() > 0) order by id limit 1", config:Fetch("admins.table_name.sanctions"), steamid, SANCTION_BAN))
    return (#sanctions > 0)
end)