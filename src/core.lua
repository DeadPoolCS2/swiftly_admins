events:on("OnPluginStart", function()
    db = Database("swiftly_admins")
    if db:IsConnected() == 0 then return end
        
    local result = db:Query(string.format("CREATE TABLE IF NOT EXISTS `%s` ( `steamid` varchar(128) NOT NULL, `flags` text NOT NULL, `immunity` int(11) NOT NULL DEFAULT 0 ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;", config:Fetch("admins.table_name.admins")))
    if #result > 0 then
    	if result[1]["warningCounts"] == 0 then
            db:Query(string.format("ALTER TABLE `%s` ADD UNIQUE KEY `steamid` (`steamid`);", config:Fetch("admins.table_name.admins")))
        end
    end
    
    db:Query(string.format("CREATE TABLE IF NOT EXISTS `%s` ( `id` int(11) NOT NULL AUTO_INCREMENT, `sanction_player` varchar(128) NOT NULL, `sanction_type` int(11) NOT NULL, `sanction_expiretime` int(11) NOT NULL, `sanction_length` int(11) NOT NULL, `sanction_reason` text NOT NULL, `sanction_admin` varchar(128) NOT NULL, `sanction_date` timestamp NOT NULL DEFAULT current_timestamp(), PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;", config:Fetch("admins.table_name.sanctions")))
        
    LoadAdmins()
    ReloadServerAdmins()
    ReloadSanctions()
end)

function GetPluginAuthor()
    return "Swiftly Solution"
end

function GetPluginVersion()
    return "v1.0.2"
end

function GetPluginName()
    return "Swiftly Admins - Your Admin System"
end

function GetPluginWebsite()
    return "https://github.com/swiftly-solution/swiftly_admins"
end