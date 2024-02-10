function CalculateFlags(flags)
	local flg = 0
    
    for i=1,#flags do 
    	if flags[i] == ADMFLAG_ROOT then
            flg = flg | ADMFLAG_RESERVATION
            flg = flg | ADMFLAG_GENERIC
            flg = flg | ADMFLAG_KICK
            flg = flg | ADMFLAG_BAN
            flg = flg | ADMFLAG_UNBAN
            flg = flg | ADMFLAG_SLAY
            flg = flg | ADMFLAG_CHANGEMAP
            flg = flg | ADMFLAG_CONVARS
            flg = flg | ADMFLAG_CONFIG
            flg = flg | ADMFLAG_CHAT
            flg = flg | ADMFLAG_VOTE
            flg = flg | ADMFLAG_PASSWORD
            flg = flg | ADMFLAG_RCON
            flg = flg | ADMFLAG_CHEATS
            flg = flg | ADMFLAG_ROOT
        else
        	flg = (flg | flags[i]) 
        end
    end
    
    return flg
end

function LoadAdmins()
    admins = {}
    adminImmunities = {}
    
    if db:IsConnected() == 0 then return end
	local result = db:Query(string.format("select * from %s", config:Fetch("admins.table_name.admins")))
    if #result > 0 then
       	for i=1,#result do 
        	local steamid = result[i].steamid
            local immunity = result[i].immunity
            local flags = result[i].flags

            if immunity < 0 then
            	logger:Write(LogType.Warning, "Immunity for '"..steamid.."' can't be negative, automatically setting it to 0")
                immunity = 0
            end
            
            local giveFlags = {}
            for i=1,string.len(flags) do
                local flag = flags:sub(i,i)
               	if flagsPermissions[flag] then
                    table.insert(giveFlags, flagsPermissions[flag])
                else
                	logger:Write(LogType.Warning, "Invalid flag for '"..steamid.."': '"..flag.."'")
                end
            end
            
            local calculatedFlags = CalculateFlags(giveFlags)
            giveFlags = {}
            
            admins[steamid] = calculatedFlags
            adminImmunities[steamid] = immunity
        end 
    end
end

function LoadAdmin(player)
    player:vars():Set("admin.flags" , 0)
    player:vars():Set("admin.immunity" , 0)
    
    local steamid = tostring(player:GetSteamID())
    if admins[steamid] then
        player:vars():Set("admin.flags" , admins[steamid])
    	player:vars():Set("admin.immunity" , adminImmunities[steamid])
    end
end

function ReloadServerAdmins()
    LoadAdmins()
    for i=0,playermanager:GetPlayerCap()-1,1 do 
    	local player = GetPlayer(i)
        if not player then goto continue end
        if player:IsFakeClient() == 1 then goto continue end
        LoadAdmin(player)
        ::continue::
    end
end

function HasValidFlags(flags)
   	for i=1,string.len(flags) do 
    	if not flagsPermissions[flags:sub(i,i)] then return false end
    end 
    return true
end
