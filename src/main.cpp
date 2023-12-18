#include <swiftly/swiftly.h>
#include <swiftly/server.h>
#include <swiftly/database.h>
#include <swiftly/commands.h>
#include <swiftly/configuration.h>
#include <swiftly/logger.h>
#include <swiftly/gameevents.h>
#include <swiftly/timers.h>
#include <main.h>

Server *server = nullptr;
PlayerManager *g_playerManager = nullptr;
Database *db = nullptr;
Commands *commands = nullptr;
Configuration *config = nullptr;
Logger *logger = nullptr;
Timers *timers = nullptr;

std::map<uint64_t, int> admins;
std::map<uint64_t, int> adminImmunities;

void OnProgramLoad(const char *pluginName, const char *mainFilePath)
{
    Swiftly_Setup(pluginName, mainFilePath);

    server = new Server();
    g_playerManager = new PlayerManager();
    commands = new Commands(pluginName);
    config = new Configuration();
    logger = new Logger(mainFilePath, pluginName);
    timers = new Timers();
}

void OnPluginStart()
{
    db = new Database(DATABASE_CONNECTION);

    if (!db->IsConnected())
        return;

    DB_Result result = db->Query("CREATE TABLE IF NOT EXISTS `%s` ( `steamid` varchar(128) NOT NULL, `flags` text NOT NULL, `immunity` int(11) NOT NULL DEFAULT 0 ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;", config->Fetch<const char *>("admins.table_name.admins"));
    if (result.size() > 0)
        if (db->fetchValue<int>(result, 0, "warningCounts") == 0)
            db->Query("ALTER TABLE `%s` ADD UNIQUE KEY `steamid` (`steamid`);", config->Fetch<const char *>("admins.table_name.admins"));

    result = db->Query("CREATE TABLE IF NOT EXISTS `%s` ( `id` int(11) NOT NULL, `sanction_player` varchar(128) NOT NULL, `sanction_type` int(11) NOT NULL, `sanction_expiretime` int(11) NOT NULL, `sanction_length` int(11) NOT NULL, `sanction_reason` text NOT NULL, `sanction_admin` varchar(128) NOT NULL, `sanction_date` timestamp NOT NULL DEFAULT current_timestamp() ) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;", config->Fetch<const char *>("admins.table_name.sanctions"));
    if (result.size() > 0)
        if (db->fetchValue<int>(result, 0, "warningCounts") == 0)
            db->Query("ALTER TABLE `%s` ADD PRIMARY KEY (`id`); ALTER TABLE `%s` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;", config->Fetch<const char *>("admins.table_name.sanctions"), config->Fetch<const char *>("admins.table_name.sanctions"));

    LoadAdmins();
    ReloadServerAdmins();
    ReloadSanctions();
    RegisterCommands();

    timers->RegisterTimer(1000, SanctionExpireCheck);
}

void OnPluginStop()
{
    admins.clear();
    adminImmunities.clear();
}

const char *GetPluginAuthor()
{
    return "Swiftly Solutions";
}

const char *GetPluginVersion()
{
    return "1.0.0";
}

const char *GetPluginName()
{
    return "Swiftly Admins - Your Admin System";
}

const char *GetPluginWebsite()
{
    return "https://github.com/swiftly-solution/swiftly_admins";
}