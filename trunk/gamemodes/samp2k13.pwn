// credits to RealCop228

#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <streamer>
#include <foreach>
#include <md5>

#define SERVER_VERSION          ".1r1"


#define MYSQL_HOST              "db4free.net"
#define MYSQL_USER              "samp2k13"
#define MYSQL_DB                "samp2013"
#define MYSQL_PASS              "db123456"


#define mysql_fetch_row(%1)     mysql_fetch_row_format(%1,"|")

                  
#define GivePlayerCash(%0,%1)   SetPVarInt(%0,"Money", GetPlayerCash(%0)+%1), GivePlayerMoney(%0,%1) // ServerSide Money (credits to Luka P.)
#define ResetPlayerCash(%0)     SetPVarInt(%0,"Money", 0), ResetPlayerMoney(%0)
#define GetPlayerCash(%0)       GetPVarInt(%0,"Money")

#define ERRORMESSAGE_ADMIN_CMD          "** Dein AdminLevel ist dafür zu niedrig."
#define ERRORMESSAGE_ADMIN_NOTONDUTY    "** Du bist nicht On-Duty."
#define ERRORMESSAGE_NOVEHICLE			"** Du bist in keinem Vehikel."
#define ERRORMESSAGE_USER_NOTLOGGEDIN   "* Du bist nicht eingeloggt."
#define ERRORMESSAGE_USER_ID_NOTONLINE  "* Dieser Spieler ist nicht online bzw. eingeloggt."
#define ERRORMESSAGE_FACTIONRANK_TOOLOW "* Dein Fraktionsrang ist dafür zu niedrig."

#define CARMENU 25000
#define MAX_PING 550

#define COLOR_WHITE     0xFFFFFFFF                // standard
#define COLOR_GREY      0xAFAFAFFF                // usage messages
#define COLOR_PURPLE    0xC2A2DADD                // admin messages
#define COLOR_RED       0xAA333333                // error messages
#define COLOR_OOC       0xFF9900AA                // ooc messages
#define COLOR_LIGHTBLUE 0x33CCFFAA                // me/do messages

#define PLAYER_DIALOG_LOGIN 					0
#define PLAYER_DIALOG_REGISTER 					1
#define PLAYER_DIALOG_CLICKED       			2
#define PLAYER_DIALOG_CLICKEDADM    			3
#define PLAYER_DIALOG_CLICKEDADM_MENU 			4

#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_ACCOUNT   0
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICK      1
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_BAN       2
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_GOTO      3
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_GETHERE   4
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_FREEZE    5
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARN      6
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_MUTE      7

#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICKRSN   6
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_BANRSN    7
#define PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARNRSN   8


forward ClearTextSpam(playerid);
forward ClearCommandSpam(playerid);
forward ChangeWeather();
forward NearByMessage(playerid, color, string[]);
forward SendAdminMessage(color, string[], requireduty);
forward ResetUnusedDBVehicles();
forward AntiCheat();

enum PlayerData
{
    pUsername[25],
    pPassword[129],
    pEmail[129],
    pIPAddress[17],
    pAdminLevel,
    pFaction,
    pFactionRank,
    pJob,
    pCash,
    pCC,
    pLevel,
    pSkin,
    Float: pHealth,
    Float: pArmor,
    Float: pPositionX,
    Float: pPositionY,
    Float: pPositionZ,
    Float: pPositionA,
    pLogins,
    pWarns,
    pWarning1,
    pWarning2,
    pWarning3,
    pVeh1,
    pVeh2,
    pVeh3,
    pLicenseCar,
    pLicenseBike,
    pLicenseAir
};
new pStats[MAX_PLAYERS][PlayerData];

enum VehicleData
{
    vVehicleID,
    vOwner,
    vModelID,
    Float: vPositionX,
    Float: vPositionY,
    Float: vPositionZ,
    Float: vPositionA,
    vColor1,
    vColor2
};
new Vehicles[MAX_VEHICLES][VehicleData];

new query[715], motd[128], taxes;
new CurrentSpawnedVehicle[MAX_PLAYERS];
new pickupHospitalLow, pickupHospitalUp, pickupParlamentOut, pickupParlamentIn;
new pickupStoreOut, pickupStoreIn;

native sscanf(const data[], const format[], {Float,_} :...);
native unformat(const data[], const format[], {Float,_} :...) = sscanf;

main() {}

public OnGameModeInit()
{
    mysql_debug(1);
    mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);

    foreach(Player, i) OnPlayerConnect(i);
    SetTimer("ChangeWeather", 2700007, true); // 45min
	SetTimer("AntiCheat", 5003, true);

    mysql_query("SELECT `motd` FROM `configuration`");
    mysql_store_result();
    if(mysql_retrieve_row()) {
        mysql_fetch_field_row(motd, "motd");
    }
    mysql_free_result();

	mysql_query("SELECT `taxes` FROM `configuration`");
	mysql_store_result();
	taxes = mysql_fetch_int(); mysql_free_result();

	printf("Database information:\r\n- MOTD: %s\r\n- TAXES: %d", motd, taxes);

    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    LimitGlobalChatRadius(20.0);
	//ManualVehicleEngineAndLights();
    SetGameModeText("SSRP");
    SetNameTagDrawDistance(20.0);
    ShowNameTags(1);
    UsePlayerPedAnims();

    LoadVehiclesFromDatabase();

	AddStaticVehicle(416,1178.0715,-1308.3512,14.0024,269.4829,1,0); // Krankenwagen1
	AddStaticVehicle(416,1178.0037,-1338.9781,14.0427,271.4690,1,0); // Krankenwagen2
	AddStaticVehicle(416,1123.5791,-1328.7023,13.4239,0.3476,1,0); // Krankenwagen3(hinten)
	AddStaticVehicle(563,1161.8552,-1377.1299,27.3177,268.7520,1,0); // Helikopter
	
	pickupHospitalLow = CreatePickup(1318, 1, 1172.0779, -1325.4570, 15.4076, -1);
	pickupHospitalUp  = CreatePickup(1318, 1, 1163.7961, -1342.8069, 26.6160, -1);
	pickupParlamentOut = CreatePickup(1318, 1, 1310.0339, -1367.0052, 13.5151, -1);
	//pickupParlamentIn =
	pickupStoreOut = CreatePickup(1318, 1, 1471.2391, -1177.9728, 23.9215, -1);
	//pickupStoreIn = CreatePickup(1318, 1, 1471.2391, -1177.9728, 23.9215, -1);


	Create3DTextLabel("Krankenhausdach", COLOR_WHITE, 1172.0779, -1325.4570, 90.0, -1, 0);
	Create3DTextLabel("Parlament", COLOR_WHITE, 1310.0339, -1367.0052, 353.0, -1, 0);
	Create3DTextLabel("Store", COLOR_WHITE, 1471.2391, -1177.9728, 23.9215, 221.0, -1, 0);
	
    return true;
}


public OnGameModeExit()
{
    foreach(Player, i) SavePlayerAccount(i);
    foreach(Player, i) OnPlayerDisconnect(i, 2);
    mysql_close();
    return true;
}


public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid);
    return true;
}


public OnPlayerConnect(playerid)
{
    new string[128];
    format(string, sizeof(string), "* %s [ID: %d] hat den Server betreten.", GetName(playerid), playerid);
    SendClientMessageToAll(COLOR_OOC, string);

    ResetPlayerVariables(playerid);
    format(query, sizeof(query), "SELECT * FROM `Accounts` WHERE `username` = '%s'", GetEscName(playerid)); mysql_query(query); mysql_store_result();
    for(new i = 0; i < 10; i++) SendClientMessage(playerid, COLOR_GREY, " ");

    if(mysql_num_rows() > 0) {
        mysql_free_result();
        ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein gewähltes Passwort ein.", "Login", "Abbrechen");
    }
    else {
        mysql_free_result();
        ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "Account", "Dieser Account ist noch nicht registriert.\r\nBitte hole dies auf www.suchtstation.de nach.", "OK", " ");
        Kick(playerid);
    }
    return true;
}


public OnPlayerDisconnect(playerid, reason)
{
    new string[128];
    switch(reason) {
        case 0: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen. [Timeout]",         GetName(playerid), playerid);
        case 1,2: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen.",                   GetName(playerid), playerid);
        //case 2: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen. [Kicked/Banned]",   GetName(playerid), playerid);
    }
    SendClientMessageToAll(COLOR_OOC, string);

    if(reason == 1 && GetPVarInt(playerid, "Authentication") == 1) {
        SetPVarInt(playerid, "LoggingOut", 1);
        SavePlayerAccount(playerid);
    }
    return true;
}


public OnPlayerSpawn(playerid)
{
    if(GetPVarInt(playerid, "JustRegistered") == 1) {
        GivePlayerCash(playerid, 100);
        SetPlayerScore(playerid, 1);
        SetPlayerSkin(playerid, random(299));
        SetPlayerPos(playerid, -2706.5261, 397.7129, 4.3672);
        SetPVarInt(playerid, "JustRegistered", 0);
        SavePlayerAccount(playerid);
        return true;
    }
    if(GetPVarInt(playerid, "JustLogged") == 1) {
        SetPVarInt(playerid, "JustLogged", 0);

        new string[128]; format(string, sizeof(string), "* Willkommen auf dem SuchtStation-RolePlay Server v%s.", SERVER_VERSION);
        SendClientMessage(playerid, COLOR_OOC, string);

        LoadPlayerAccount(playerid);
        return true;
    }
    
    if(GetPVarInt(playerid, "JustDied") == 1) {
        SetPlayerSkin(playerid, pStats[playerid][pSkin]);
        SetPlayerPos(playerid, 1184.9803, -1323.1014, 13.5730);
        SetPlayerFacingAngle(playerid, 268.7873);
        if(GetPlayerCash(playerid) > 60) GivePlayerCash(playerid, -60);
        SetPVarInt(playerid, "JustDied", 0);
        return true;
    }
    
	if(pStats[playerid][pFaction] == 1) {     // Polizei

		SetPlayerPos(playerid, -1606.4093,673.4142,-5.2422);
		SetPlayerFacingAngle(playerid, 359.0151);
		
		
	//	AddPlayerClass(0,-2665.5969,-2.1069,6.1328,93.2043,0,0,0,0,0,0); // Bank1
	//	AddPlayerClass(0,-2666.0901,-9.2802,6.1328,90.6976,0,0,0,0,0,0); // Bank2
		return true;
    }
    
    if(pStats[playerid][pFaction] == 2) {     // Arzt
		SetPlayerPos(playerid, 1178.3900, -1325.5103, 14.1177);
		SetPlayerFacingAngle(playerid, 359.0151);

		return true;
    }
    
    if(pStats[playerid][pFaction] == 3) {     // Fahrschule
		SetPlayerPos(playerid, -1606.4093, 673.4142, -5.2422); // 0
		SetPlayerFacingAngle(playerid, 180.1302);

		return true;
    }
    
    if(pStats[playerid][pFaction] == 4) {     // ADAC
		SetPlayerPos(playerid, -1606.4093, 673.4142, -5.2422); // 0
		SetPlayerFacingAngle(playerid, 359.0151);

		return true;
    }
    
	if(pStats[playerid][pFaction] == 5) {     // Taxi
		SetPlayerPos(playerid, -1977.5164, 102.5072, 27.6875);
		SetPlayerFacingAngle(playerid, 88.0719);

		return true;
    }
    
    return true;
}


public OnPlayerDeath(playerid, killerid, reason)
{
    SetPVarInt(playerid, "JustDied", 1);
    return true;
}


public OnVehicleSpawn(vehicleid) return true;
public OnVehicleDeath(vehicleid, killerid) return true;


public OnPlayerText(playerid, text[])
{
    new string[128];
    if(GetPVarInt(playerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, "* Du musst eingeloggt sein um sprechen zu können.");

    /*SetPVarInt(playerid, "TextSpam", GetPVarInt(playerid, "TextSpam") + 1);
    SetTimerEx("ClearTextSpam", 2000, false, "d", playerid);

    if(GetPVarInt(playerid,"TextSpam") == 15) {
        format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Spamming.", GetName(playerid), playerid);
        SendClientMessageToAll(COLOR_RED, string);
        CallRemoteFunction("KickIncrease", "d", playerid);
        Kick(playerid);
    }

    else if(GetPVarInt(playerid, "TextSpam") == 10) {
        SendClientMessage(playerid, COLOR_RED, "* SERVER: Spamming führt zu einem Kick.");
        return false;
    }*/

    else if(GetPVarInt(playerid, "PlayerMuted") == 1) {
        SendClientMessage(playerid, COLOR_RED, "* Du bist momentan stumm gestellt und kannst nicht reden.");
        return false;
    }

    else if(text[0] == '@' && pStats[playerid][pAdminLevel] >= 1) {
        format(string, sizeof(string), "** Admin %s: %s", GetName(playerid), text);
        SendAdminMessage(COLOR_PURPLE, string, 0);
        
       	format(string, sizeof(string), "[ADMIN] %s: %s", GetName(playerid), text);
    	Log2File("chat", string);
        return false;
    }
	format(string, sizeof(string), "[SAY] %s: %s", GetName(playerid), text);
    Log2File("chat", string);
    return true;
}


// admin commands ascending
// adminlevel 1

command(ahelp, playerid, params[])
{
#pragma unused params
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

    //if(pStats[playerid][pAdminLevel] >= 1)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 1: /adminduty /kick /ban /warn /mute");
	if(pStats[playerid][pAdminLevel] >= 1)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 1: /adminduty /say");
	//if(pStats[playerid][pAdminLevel] >= 2)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 2: /goto /gethere /freeze /spawnveh /respawnveh /respawnaveh /repairveh");
	if(pStats[playerid][pAdminLevel] >= 2)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 2: /spawnveh /respawnveh /respawnaveh /repairveh");
	if(pStats[playerid][pAdminLevel] == 3)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 3: /makeadmin /motd /set /announce");
    return true;
}


command(ah, playerid, params[])
{
#pragma unused params
    return cmd_adminduty(playerid, params);
}


command(adminduty, playerid, params[])
{
#pragma unused params

    new string[128];

    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

    if(GetPVarInt(playerid, "AdminDuty") == 0) {
        SetPVarInt(playerid, "AdminDuty", 1);
        format(string, sizeof(string), "** Administrator %s [ID: %d] ist nun On-Duty.", GetName(playerid), playerid);
        GetPlayerHealth(playerid, pStats[playerid][pHealth]);
        SetPlayerHealth(playerid, 999999999.99);
        SetPlayerColor(playerid, COLOR_PURPLE);
    }
    else if(GetPVarInt(playerid, "AdminDuty") == 1) {
        SetPVarInt(playerid, "AdminDuty", 0);
        format(string, sizeof(string), "** Administrator %s [ID: %d] ist nun Off-Duty.", GetName(playerid), playerid);
        SetPlayerHealth(playerid, 100.0);
        SetPlayerColor(playerid, COLOR_WHITE);
    }
    SendClientMessageToAll(COLOR_PURPLE, string);
    Log2File("admin", string);
    return true;
}


command(aduty, playerid, params[])
{
#pragma unused params
    return cmd_adminduty(playerid, params);
}


/*
command(kick, playerid, params[])
{
    new string[128], reason[105], giveplayerid;
    if(pStats[playerid][pAdminLevel] < 1) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "uS(No Reason Given)[128]", giveplayerid, reason)) 					return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /kick [SpielerID] [Grund]");
    if(pStats[playerid][pAdminLevel] < pStats[giveplayerid][pAdminLevel])					return SendClientMessage(playerid, COLOR_RED, "** Du kannst keinen Administrator mit einem höheren AdminLevel kicken.");
    if(GetPVarInt(giveplayerid, "Authentication") != 1)									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);

    format(string, sizeof(string), "** Du wurdest von Administrator %s gekickt. Grund: %s", GetName(playerid), reason);
    SendClientMessage(giveplayerid, COLOR_RED, string);

	format(string, sizeof(string), "** Administrator %s hat %s gekickt. Grund: %s", GetName(playerid), GetName(giveplayerid), reason);
	SendClientMessageToAll(COLOR_PURPLE, string);
	Log2File("admin", string);

	Kick(giveplayerid);
	return true;
}

command(ban, playerid, params[])
{
	new string[128], reason[105], giveplayerid;
	if(pStats[playerid][pAdminLevel] < 1)										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
	if(sscanf(params, "us[128]", giveplayerid, reason))									return SendClientMessage(playerid, COLOR_GREY,  "* Verwendung: /ban [SpielerID] [Grund]");
	if(pStats[playerid][pAdminLevel] < pStats[giveplayerid][pAdminLevel])					return SendClientMessage(playerid, COLOR_RED, "** Du kannst keinen Administrator mit einem höheren AdminLevel bannen.");
	if(GetPVarInt(giveplayerid, "Authentication") != 1)									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);

	format(string, sizeof(string), "** Du wurdest von Administrator %s gebannt. Grund: %s", GetName(playerid), reason);
	SendClientMessage(giveplayerid, COLOR_RED, string);

	format(string, sizeof(string), "** Administrator %s hat %s gebannt. Grund: %s", GetName(playerid), GetName(giveplayerid), reason);
	SendClientMessageToAll(COLOR_PURPLE, string);
    Log2File("admin", string);
	BanEx(giveplayerid, reason);
	Kick(giveplayerid);
	return true;
}

command(warn, playerid, params[])
{
	new string[128], reason[128], giveplayerid;
	if(pStats[playerid][pAdminLevel] < 1) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
	if(sscanf(params, "us[128]", giveplayerid, reason)) 									return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /warn [SpielerID] [Grund]");
	if(GetPVarInt(giveplayerid, "Authentication") != 1) 									return SendClientMessage(playerid, COLOR_RED,  ERRORMESSAGE_USER_ID_NOTONLINE);

	pStats[giveplayerid][pWarns] ++;
		if(pStats[giveplayerid][pWarns] == -1) {
		format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt. Grund: %s", GetName(playerid), GetName(giveplayerid), giveplayerid, reason);
		SendClientMessageToAll(COLOR_PURPLE, string);
		SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 1/3 gestiegen.");

		format(query, sizeof(query), "UPDATE `Accounts` SET `warning1` = '%s' WHERE `username` = '%s'", reason, GetName(giveplayerid));
		mysql_query(query);
		pStats[playerid][pWarns] ++;
	}
	else if(pStats[giveplayerid][pWarns] == 1) {
		format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt. Grund: %s [2/3]", GetName(playerid), GetName(giveplayerid), giveplayerid, reason);
		SendClientMessageToAll(COLOR_PURPLE, string);
		SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 2/3 gestiegen.");

		format(query, sizeof(query), "UPDATE `Accounts` SET `warning2` = '%s' WHERE `username` = '%s'", reason, GetName(playerid));
		mysql_query(query);
	}
	else if(pStats[playerid][pWarns] == 2) {
		format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt. Grund: %s [3/3]", GetName(playerid), GetName(giveplayerid), giveplayerid, reason);
		SendClientMessageToAll(COLOR_PURPLE, string);
		format(string, sizeof(string), "** %s [ID: %d] wurde aufgrund von zuvielen Verwarnungen vom Server gebannt.", GetName(giveplayerid), giveplayerid);
		SendClientMessageToAll(COLOR_PURPLE, string);

		format(query, sizeof(query), "UPDATE `Accounts` SET `warning3` = '%s' WHERE `username` = '%s'", reason, GetName(playerid));
		mysql_query(query);

		Kick(giveplayerid);
	}
	else SendClientMessage(playerid, COLOR_RED, "* SERVER: Bei dieser Interaktion ist ein Fehler aufgetreten. (Errorcode: #001)");
	SavePlayerAccount(playerid);
    Log2File("admin", string);
	return true;
}

command(mute, playerid, params[])
{
    new string[128], giveplayerid;
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "u", giveplayerid))               return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /mute [SpielerID]");
    if(GetPVarInt(giveplayerid, "Authentication") != 1)     return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);

    if(GetPVarInt(giveplayerid, "PlayerMuted") == 0) {
        SetPVarInt(giveplayerid, "PlayerMuted", 1);

        format(string, sizeof(string), "** Administrator %s hat dich stumm gestellt.", GetName(playerid));
        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** Du hast %s stumm gestellt.", GetName(giveplayerid));
        SendClientMessage(playerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** Administrator %s hat %s stumm gestellt.", GetName(playerid), GetName(giveplayerid));
    }
    else {
        SetPVarInt(playerid, "PlayerMuted", 0);

        format(string, sizeof(string), "** Administrator %s hat dich entstummt (lol, pls changeme).", GetName(playerid));
        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** Du hast %s entstummt.", GetName(giveplayerid));
        SendClientMessage(playerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** Administrator %s hat %s entstummt.", GetName(playerid), GetName(giveplayerid));
    }
    Log2File("admin", string);
    return true;
}


// adminlevel 2

command(goto, playerid, params[])
{
    new giveplayerid;
    if(pStats[playerid][pAdminLevel] < 2) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params)) 															return SendClientMessage(playerid, COLOR_GREY,  "* Verwendung:/goto [Ort]"),
                       SendClientMessage(playerid, COLOR_WHITE, "* Parameter: ls, sf, lv");
    if(GetPVarInt(playerid, "AdminDuty") == 0) 									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_NOTONDUTY);
    if(GetPVarInt(giveplayerid, "Authentication") != 1)									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);

	if(IsPlayerInAnyVehicle(playerid)) {
		GetPlayerPos(giveplayerid, X, Y, Z);
		vehicle = GetPlayerVehicleID(playerid);
		SetVehiclePos(vehicle, X+2, Y, Z);
		PutPlayerInVehicle(playerid, vehicle, 0);
	}
	else {
		GetPlayerPos(giveplayerid, X, Y, Z);
		SetPlayerPos(playerid, X+4, Y, Z);
	}
	format(string, sizeof(string), "** Du hast dich zu %s teleportiert.", GetName(giveplayerid));
	SendClientMessage(playerid, COLOR_PURPLE, string);

	format(string, sizeof(string), "** Administrator %s hat sich zu %s teleportiert.", GetName(playerid), GetName(giveplayerid));
    Log2File("admin", string);
	return true;
}

command(gethere, playerid, params[])
{
	new string[128], giveplayerid, vehicle;
	new Float:X, Float:Y, Float:Z;
	if(pStats[playerid][pAdminLevel] < 2) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
	if(GetPVarInt(playerid, "AdminDuty") == 0) 									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_NOTONDUTY);
	if(GetPVarInt(giveplayerid, "Authentication") != 1)									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);
	if(sscanf(params, "u", giveplayerid)) 												return SendClientMessage(playerid, COLOR_GREY, "* Verwendung:/gethere [SpielerID]"),
																				               SendClientMessage(playerid, COLOR_WHITE, "Function: Will teleport the specified player to your position.");
																				               
	if(IsPlayerInAnyVehicle(giveplayerid)) {
		GetPlayerPos(playerid, X, Y, Z);
		vehicle = GetPlayerVehicleID(giveplayerid);
		SetVehiclePos(vehicle, X+2, Y, Z);
		PutPlayerInVehicle(giveplayerid, vehicle, 0);
	}
	else {
		GetPlayerPos(playerid, X, Y, Z);
		SetPlayerPos(giveplayerid, X+2, Y, Z);
	}
	format(string, sizeof(string), "** Du wurdest zu Administrator %s teleportiert.", GetName(playerid));
	SendClientMessage(giveplayerid, COLOR_PURPLE, string);

	format(string, sizeof(string), "** Du hast %s zu dir teleportiert.", GetName(giveplayerid));
	SendClientMessage(playerid, COLOR_PURPLE, string);

	format(string, sizeof(string), "** Administrator %s hat %s zu sich teleportiert.", GetName(playerid), GetName(giveplayerid));
    Log2File("admin", string);
	return true;
}

command(freeze, playerid, params[])
{
	new string[128], giveplayerid;
	if(pStats[playerid][pAdminLevel] < 2) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
	if(sscanf(params, "u", giveplayerid))													return SendClientMessage(playerid, COLOR_GREY,  "* Verwendung: /freeze [SpielerID]");
	if(GetPVarInt(giveplayerid, "Authentication") != 1)									return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);

	if(GetPVarInt(giveplayerid, "PlayerFrozen") == 0) {
		TogglePlayerControllable(giveplayerid, false);
		SetPVarInt(giveplayerid, "PlayerFrozen", 1);

		format(string, sizeof(string), "** Administrator %s hat dich eingefroren.", GetName(playerid));
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** Du hast %s eingefroren", GetName(giveplayerid));
		SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** Administrator %s hat %s eingefroren.", GetName(playerid), GetName(giveplayerid));
	}
	else {
		TogglePlayerControllable(giveplayerid, true);
		SetPVarInt(giveplayerid, "PlayerFrozen", 0);

		format(string, sizeof(string), "** Administrator %s hat dich aufgetaut.", GetName(playerid));
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** Du hast %s aufgetaut", GetName(giveplayerid));
		SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** Administrator %s hat %s aufgetaut.", GetName(playerid), GetName(giveplayerid));
	}
    Log2File("admin", string);
	return true;
}

*/

command(spawnveh, playerid, params[])
{
    new val, color1, color2, string[128];
    new Float:X, Float:Y, Float:Z, Float:A;
    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "iii", val, color1, color2))                      return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /spawncar [VehikelID] [Farbe1] [Farbe2]");

    if(val < 400 || val > 600) return SendClientMessage(playerid, COLOR_RED, "** Ungültige VehikelID/Name.");

    if(IsPlayerInAnyVehicle(playerid)) {
        new vehicleid = GetPlayerVehicleID(playerid);
        DestroyVehicle(vehicleid);
    }

    GetPlayerPos(playerid, X, Y, Z);
    GetPlayerFacingAngle(playerid, A);
    CurrentSpawnedVehicle[playerid] = CreateVehicle(val, X, Y, Z, A, color1, color2, -1);
    LinkVehicleToInterior(CurrentSpawnedVehicle[playerid], GetPlayerInterior(playerid));
    PutPlayerInVehicle(playerid, CurrentSpawnedVehicle[playerid], 0);

	format(string, sizeof(string), "** Administrator %s hat sich ein Vehikel mit der ID %d gespawned.", GetName(playerid), val);
    Log2File("admin", string);
	return true;
}


command(respawncar, playerid, params[])
{
#pragma unused params

    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerInAnyVehicle(playerid))         return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);
    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	return true;
}


command(respawnaveh, playerid, params[])
{
#pragma unused params

    new bool:VehicleUsed[MAX_VEHICLES] = false, string[128];

    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

    foreach(Player, i) if(IsPlayerInAnyVehicle(i)) VehicleUsed[GetPlayerVehicleID(i)] = true;
    for(new v = 1; v != MAX_VEHICLES; v++) if(VehicleUsed[v] == false) SetVehicleToRespawn(v);

    format(string, sizeof(string), "** Administrator %s hat alle unbenutzten Vehikel zurückgesetzt.", GetName(playerid), playerid);
    SendClientMessageToAll(COLOR_PURPLE, string);
    Log2File("admin", string);
	return true;
}

command(test, playerid, params[])
{
#pragma unused params
	ResetUnusedDBVehicles();
}


command(repairveh, playerid, params[])
{
    new string[128], giveplayerid;
    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "u", giveplayerid))                   return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /repairveh [SpielerID]"),
            SendClientMessage(playerid, COLOR_WHITE, "Function: Will repair the specified players vehicle - health and body.");
    if(GetPVarInt(giveplayerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);
    if(!IsPlayerInAnyVehicle(giveplayerid))             return SendClientMessage(playerid, COLOR_RED, "** Dieser Spieler ist in keinem Vehikel.");

    RepairVehicle(GetPlayerVehicleID(giveplayerid));
    PlayerPlaySound(giveplayerid, 1133, -1, -1, -1);

    format(string, sizeof(string), "** Administrator %s hat dein Vehikel repariert.", GetName(playerid));
    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Du hast das Vehikel von %s repariert.", GetName(giveplayerid));
    SendClientMessage(playerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Administrator %s hat das Vehikel von %s repariert.", GetName(playerid), GetName(giveplayerid));
    Log2File("admin", string);
	return true;
}


/*command(saveveh, playerid, params[])
{
    new Color1, Color2, Float:PositionX, Float:PositionY, Float:PositionZ, Float:AngleZ;
    new vehicleid = GetPlayerVehicleID(playerid);
    new ModelID = GetVehicleModel(vehicleid);

    if(pStats[playerid][pAdminLevel] < 3)										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerInAnyVehicle(playerid))											return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);

    GetVehiclePos(vehicleid, PositionX, PositionY, PositionZ);
    GetVehicleZAngle(vehicleid, AngleZ);
	GetVehicleColor(vehicleid, Color1, Color2);

	format(query, sizeof(query), "INSERT INTO `Vehicles` (model, position_X, position_Y, position_Z, angle, color1, color2) VALUES(%d, %f, %f, %f, %f, %d, %d)", ModelID, PositionX, PositionY, PositionZ, AngleZ, Color1, Color2);
	mysql_query(query);
	return true;
}

command(deleteveh, playerid, params[])
{
#pragma unused params

	new currentveh;

	if(pStats[playerid][pAdminLevel] < 3) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
	if(!IsPlayerInAnyVehicle(playerid)) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);

	currentveh = GetPlayerVehicleID(playerid);
	DestroyVehicle(currentveh);

	SendClientMessage(playerid, COLOR_WHITE, "** Du hast das Vehikel erfolgreich entfernt.");
	return true;
}
*/

// adminlevel 3

command(makeadmin, playerid, params[])
{
    new giveplayerid, level, string[128];
    if(!IsPlayerAdmin(playerid)/* && pStats[playerid][pAdminLevel] < 3*/)       return false;
    if(sscanf(params, "ud", giveplayerid, level))           return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /setadmin [SpielerID] [Level (1-3)]");
    if(level == pStats[giveplayerid][pAdminLevel])      return SendClientMessage(playerid, COLOR_RED, "** Dieser Spieler besitzt bereits dieses AdminLevel.");

    pStats[giveplayerid][pAdminLevel] = level;
    SavePlayerAccount(giveplayerid);

    format(string, sizeof(string), "** %s hat dein AdminLevel auf %d gesetzt.", GetName(playerid), level);
    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Du hast das AdminLevel von %s [ID: %d] auf %d gesetzt.", GetName(giveplayerid), giveplayerid, level);
    SendClientMessage(playerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Administrator %s hat das AdminLevel von %s auf %d gesetzt.", GetName(playerid), GetName(giveplayerid), giveplayerid, level);
	Log2File("admin", string);
    return true;
}


command(motd, playerid, params[])
{
    new string[128];
    if(pStats[playerid][pAdminLevel] < 3)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /motd [Nachricht]"),

    format(string, sizeof(string), "\r\n%s\r\n", params);
    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "MOTD", string, "OK", " ");

    mysql_real_escape_string(params, motd);
    if(mysql_num_fields() != 0) format(query, sizeof(query), "UPDATE `configuration` SET `motd` = '%s'", motd);
    else format(query, sizeof(query), "INSERT INTO `configuration` (`motd`) VALUES('%s')", motd);
    mysql_query(query);
    return true;
}


command(say, playerid, params[])
{
    new string[128];
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /say [Nachricht]"),
    format(string, sizeof(string), "** Admin: %s", params);
    SendClientMessageToAll(COLOR_PURPLE, string);

	format(string, sizeof(string), "** Admin %s [/say]: %s", GetName(playerid), params);
    Log2File("admin", string);
    return true;
}


command(set, playerid, params[])
{
    new string[128], Usage[16], giveplayerid, val;

	if(pStats[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "us[16]d", giveplayerid, Usage, val))                             return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /set [SpielerID] [Parameter] [Wert]"),
            																					SendClientMessage(playerid, COLOR_GREY, "* Parameter: Health, Armor, Interior, (V)irtual(W)orld, Skin, Cash, Level, Faction, Rank");
    if(strcmp(Usage, "skin", true) == 0) {
        SetPlayerSkin(giveplayerid, val);
        pStats[giveplayerid][pSkin] = val;

        format(string, sizeof(string), "** Du hast %s den Skin mit der ID %d gegeben.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);
    }

    else if(strcmp(Usage, "cash", true) == 0) {

        SetPVarInt(giveplayerid, "pMoney", GetPlayerMoney(playerid));

        GivePlayerCash(giveplayerid, -(GetPVarInt(giveplayerid, "pMoney")));
        GivePlayerCash(giveplayerid, val);
        pStats[giveplayerid][pCash] = val;

        format(string, sizeof(string), "** Du hast das Geld von %s auf $%d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);
        
        format(string, sizeof(string), "[SET] %s - $%d - %s.", GetName(playerid), val, GetName(giveplayerid));
    	Log2File("money", string);
    	
		format(string, sizeof(string), "** %s hat das Geld von %s auf $%d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "health", true) == 0) {
        SetPlayerHealth(giveplayerid, val);
        pStats[giveplayerid][pHealth] = val;

        format(string, sizeof(string), "** Du hast die HP von %s auf %d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat die HP von %s auf %d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "armor", true) == 0 || strcmp(Usage, "armor", true) == 0) {
        SetPlayerArmour(giveplayerid, val);
        pStats[giveplayerid][pArmor] = val;
        format(string, sizeof(string), "** Du hast die Rüstung von %s auf %d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat die Armor von %s auf %d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "vw", true) == 0 || strcmp(Usage, "virtualworld", true) == 0) {
        SetPlayerVirtualWorld(giveplayerid, val);
        format(string, sizeof(string), "** Du hast die Virtuelle Welt von %s auf %d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);
        
        format(string, sizeof(string), "** %s hat die Virtuelle Welt von %s auf %d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "interior", true) == 0) {
        SetPlayerInterior(giveplayerid, val);
        format(string, sizeof(string), "** Du hast den Interior von %s auf %d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);
        
        format(string, sizeof(string), "** %s hat den Interior von %s auf %d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "level",  true) == 0) {
        SetPlayerScore(giveplayerid, val);
        pStats[giveplayerid][pLevel] = val;
        format(string, sizeof(string), "** Du hast das Level von %s auf %d gesetzt.", GetName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);
        SavePlayerAccount(giveplayerid);
        
		format(string, sizeof(string), "** %s hat das Level von %s auf %d gesetzt", GetName(playerid), GetName(giveplayerid), val);
    	Log2File("admin", string);
    }
    else if(strcmp(Usage, "faction",  true) == 0) {
        pStats[giveplayerid][pFaction] = val;

        if(val == 1) {
			format(string, sizeof(string), "** Du hast %s der Fraktion Polizei zugeordnet.", 					GetName(giveplayerid));
	        SendClientMessage(playerid, COLOR_PURPLE, string);
	        
			format(string, sizeof(string), "** Administrator %s hat %s der Fraktion Polizei zugeordnet.", GetName(playerid), GetName(giveplayerid));
    		Log2File("admin", string);
		}
        if(val == 2) {
			format(string, sizeof(string), "** Du hast %s der Fraktion Arzt zugeordnet.",           GetName(giveplayerid));
	        SendClientMessage(playerid, COLOR_PURPLE, string);
	        
			format(string, sizeof(string), "** Administrator %s hat %s der Fraktion Arzt zugeordnet.", GetName(playerid), GetName(giveplayerid));
    		Log2File("admin", string);
		}
        if(val == 3) {
		    format(string, sizeof(string), "** Du hast %s der Fraktion Fahrschule zugeordnet.",     GetName(giveplayerid));
	        SendClientMessage(playerid, COLOR_PURPLE, string);
	        
			format(string, sizeof(string), "** Administrator %s hat %s der Fraktion Fahrschule zugeordnet.", GetName(playerid), GetName(giveplayerid));
    		Log2File("admin", string);
		}
		if(val == 4) {
		    format(string, sizeof(string), "** Du hast %s der Fraktion ADAC zugeordnet.",           GetName(giveplayerid));
	        SendClientMessage(playerid, COLOR_PURPLE, string);
	        
			format(string, sizeof(string), "** Administrator %s hat %s der Fraktion ADAC zugeordnet.", GetName(playerid), GetName(giveplayerid));
    		Log2File("admin", string);
		}
		if(val == 5) {
			format(string, sizeof(string), "** Administrator Du hast %s der Fraktion Taxifahrer zugeordnet.",     GetName(giveplayerid));
	        SendClientMessage(playerid, COLOR_PURPLE, string);

			format(string, sizeof(string), "** Administrator %s hat %s der Fraktion Taxifahrer zugeordnet.", GetName(playerid), GetName(giveplayerid));
    		Log2File("admin", string);
		}
        if(val == 1)    format(string, sizeof(string), "** %s hat dich der Fraktion Polizei zugeordnet.",       GetName(playerid));
        if(val == 2)    format(string, sizeof(string), "** %s hat dich der Fraktion Arzt zugeordnet.",          GetName(playerid));
        if(val == 3)    format(string, sizeof(string), "** %s hat dich der Fraktion Fahrschule zugeordnet.",    GetName(playerid));
        if(val == 4)    format(string, sizeof(string), "** %s hat dich der Fraktion ADAC zugeordnet.",          GetName(playerid));
        if(val == 5)    format(string, sizeof(string), "** %s hat dich der Fraktion Taxifahrer zugeordnet.",    GetName(playerid));
        SendClientMessage(giveplayerid, COLOR_PURPLE, string);
        SpawnPlayer(giveplayerid);
    }

    else if(strcmp(Usage, "rank",  true) == 0) {
        pStats[giveplayerid][pFactionRank] = val;

		format(string, sizeof(string), "** Du hast %s den Rang %d seiner Fraktion gegeben.", GetName(giveplayerid), val);
       	SendClientMessage(playerid, COLOR_PURPLE, string);
		format(string, sizeof(string), "** Administrator %s hat dir den Rang %d deiner Fraktion gegeben.", GetName(playerid), val);
        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** Administrator %s hat %s den Rang %d seiner Fraktion gegeben.", GetName(playerid), val, GetName(giveplayerid));
   		Log2File("admin", string);

		SpawnPlayer(giveplayerid);
    }
    SavePlayerAccount(giveplayerid);
    return true;
}

/*command(giveweapon, playerid, params[])       <-- in /set integrieren
{
    new string[128], id, weapon, ammo;

    if(pStats[playerid][pAdminLevel] < 3) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "udd", id, weapon, ammo))									return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /giveweapon [SpielerID] [WaffenID] [Munition]");

    GivePlayerWeapon(id, weapon, ammo);

    format(string, sizeof(string), "** Administrator %s hat dir die Waffe mit der ID %d gegeben.", GetName(playerid), weapon);
    SendClientMessage(id, COLOR_PURPLE, string);

format(string, sizeof(string), "** Du hast %s die Waffe mit der ID %d gegeben.", GetName(id), weapon);
SendClientMessage(playerid, COLOR_PURPLE, string);

format(string, sizeof(string), "** Administrator %s hat %s die Waffe mit der ID %d gegeben.", GetName(playerid), GetName(id), weapon);
return true;
}*/

command(announce, playerid, params[])
{
    new string[128];

    if(pStats[playerid][pAdminLevel] < 3)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /(ann)ounce [Nachricht]");

    format(string, sizeof(string), "*** WICHTIGE Ankündigung: %s", params);
    SendClientMessageToAll(COLOR_PURPLE, string);

	format(string, sizeof(string), "** Admin %s [/announce]: %s", GetName(playerid), params);
    Log2File("admin", string);
    return true;
}


command(ann, playerid, params[]) return cmd_announce(playerid, params);

// player

command(help, playerid, params[])
{
#pragma unused params
    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

    SendClientMessage(playerid, COLOR_OOC, "* Allgemein: /admins /afk /givecash /buy");
    SendClientMessage(playerid, COLOR_OOC, "* Chat:     /s /b /me /ooc");
    if(pStats[playerid][pFaction] == 1) 					SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
    else if(pStats[playerid][pFactionRank] == 5)			SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");

	if(pStats[playerid][pFaction] == 2) 					SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
    else if(pStats[playerid][pFactionRank] == 5)			SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");

	if(pStats[playerid][pFaction] == 3) 					SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
    else if(pStats[playerid][pFactionRank] == 5)			SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");

	if(pStats[playerid][pFaction] == 4) 					SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
    else if(pStats[playerid][pFactionRank] == 5)			SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");

	if(pStats[playerid][pFaction] == 5) 					SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
    else if(pStats[playerid][pFactionRank] == 5)			SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");
    return true;
}


command(saveacc, playerid, params[])              // debug cmd
{
#pragma unused params
    SavePlayerAccount(playerid);
    return true;
}


command(admins, playerid, params[])
{
#pragma unused params

    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

    SendClientMessage(playerid, COLOR_WHITE, "---------------------------------------------------------------------------------------------------------------------------------" );
    foreach(Player, i) {
        if(pStats[i][pAdminLevel] >= 1) {
            if(GetPVarInt(i, "AdminDuty") == 0 && GetPVarInt(i, "AFKStatus") == 1) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [AFK] [Off-Duty]", GetName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else if(GetPVarInt(i, "AdminDuty") == 0 && GetPVarInt(i, "AFKStatus") == 0) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [Off-Duty]", GetName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else if(GetPVarInt(i, "AdminDuty") == 1 && GetPVarInt(i, "AFKStatus") == 1) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [AFK]", GetName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d)", GetName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_WHITE, string);
            }
        }
        else SendClientMessage(playerid, COLOR_WHITE, "Es sind momentan keine Administratoren Online.");
        SendClientMessage(playerid, COLOR_WHITE, "---------------------------------------------------------------------------------------------------------------------------------" );
    }
    return true;
}


command(afk, playerid, params[])
{
#pragma unused params

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

    if(GetPVarInt(playerid, "AFKStatus") == 1) {
        SendClientMessage(playerid, COLOR_OOC, "* Du bist nun nicht mehr AFK.");
        SetPVarInt(playerid, "AFKStatus", 0);
        TogglePlayerControllable(playerid, true);
    }
    else if(GetPVarInt(playerid, "AFKStatus") == 0) {
        SendClientMessage(playerid, COLOR_OOC, "* Du bist nun AFK.");
        SetPVarInt(playerid, "AFKStatus", 1);
        TogglePlayerControllable(playerid, false);
    }
    return true;
}


command(s, playerid, params[])
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /s [Nachricht]");

    format(string, sizeof(string), "%s schreit: %s!!", GetNameEx(playerid), params);
    NearByMessage(playerid, COLOR_LIGHTBLUE, string);

	format(string, sizeof(string), "[S] %s schreit: %s!!", GetName(playerid), params);
    Log2File("chat", string);
    return true;
}


command(b, playerid, params[])
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /b [Nachricht]");

    format(string, sizeof(string), "(( %s: %s ))", GetNameEx(playerid), params);
    NearByMessage(playerid, COLOR_LIGHTBLUE, string);

	format(string, sizeof(string), "[B] (( %s: %s ))", GetName(playerid), params);
    Log2File("chat", string);
    return true;
}


command(me, playerid, params[])
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /me [Aktion]");

    format(string, sizeof(string), "* %s %s", GetNameEx(playerid), params);
    NearByMessage(playerid, COLOR_LIGHTBLUE, string);

	format(string, sizeof(string), "[ME] %s %s", GetName(playerid), params);
    Log2File("chat", string);
    return true;
}


command(ooc, playerid, params[])
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /o(oc) [Nachricht]");

    format(string, sizeof(string), "[OOC] %s: %s", GetNameEx(playerid), params);
    SendClientMessageToAll(COLOR_WHITE, string);

	format(string, sizeof(string), "[OOC] %s: %s", GetName(playerid), params);
    Log2File("chat", string);
    return true;
}


command(o, playerid, params[])
{
#pragma unused params
    return cmd_ooc(playerid, params);
}


command(givecash, playerid, params[])
{
    new string[128], giveplayerid, amount, Float:PosX, Float:PosY, Float:PosZ;

    if(GetPVarInt(giveplayerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(sscanf(params, "ud", giveplayerid, amount))      return SendClientMessage(playerid, COLOR_GREY,  "* Verwendung: /givecash [SpielerID] [Menge]"),

    GetPlayerPos(giveplayerid, PosX, PosY, PosZ);
    if(!IsPlayerInRangeOfPoint(playerid, 7.0, PosX, PosY, PosZ))                return SendClientMessage(playerid, COLOR_RED, "* Du bist zu weit von diesem Spieler entfernt.");

    if(giveplayerid != playerid) {
        GivePlayerCash(playerid, -amount);
        GivePlayerCash(giveplayerid, amount);
    }

    if(giveplayerid == playerid) format(string, sizeof(string), "* %s holt eine Münze aus der Tasche und spielt damit.", GetName(playerid), GetName(giveplayerid));
    else {
		format(string, sizeof(string), "* %s holt Geld aus der Tasche und gibt es %s.", GetName(playerid), GetName(giveplayerid));
    	NearByMessage(playerid, COLOR_LIGHTBLUE, string);

		format(string, sizeof(string), "[GIVECASH] %s - $%d - %s.", GetName(playerid), amount, GetName(giveplayerid));
    	Log2File("money", string);
	}

    format(string, sizeof(string), "* Du hast %s $%d gegeben.", GetName(giveplayerid), amount);
    SendClientMessage(playerid, COLOR_OOC, string);

    format(string, sizeof(string), "* Du hast $%d von %s bekommen.", amount, GetName(playerid), playerid);
    SendClientMessage(giveplayerid, COLOR_OOC, string);
    return true;
}


// faction

command(getfunds, playerid, params[])
{
	if(pStats[playerid][pFactionRank] != 5) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_FACTIONRANK_TOOLOW);

	if(pStats[playerid][pFaction] == 1) format(query, sizeof(query), "SELECT `faction_1_funds` FROM `configuration`");
	if(pStats[playerid][pFaction] == 2) format(query, sizeof(query), "SELECT `faction_2_funds` FROM `configuration`");
	if(pStats[playerid][pFaction] == 3) format(query, sizeof(query), "SELECT `faction_3_funds` FROM `configuration`");
	if(pStats[playerid][pFaction] == 4) format(query, sizeof(query), "SELECT `faction_4_funds` FROM `configuration`");
	if(pStats[playerid][pFaction] == 5) format(query, sizeof(query), "SELECT `faction_5_funds` FROM `configuration`");

	mysql_query(query); mysql_store_result();
	new val = mysql_fetch_int(); mysql_free_result();
	
	new string[128];
	format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", val);
	SendClientMessage(playerid, COLOR_OOC, string);
	return true;
}


public OnPlayerCommandReceived(playerid, cmdtext[])
{
    new string[128];

    if(pStats[playerid][pAdminLevel] < 1) {
        SetPVarInt(playerid, "CommandSpam", GetPVarInt(playerid, "CommandSpam") + 1);
        SetTimerEx("ClearCommandSpam", 1000, false, "d", playerid);

        if(GetPVarInt(playerid, "CommandSpam") > 5)     return SendClientMessage(playerid, COLOR_RED, "* SERVER: Du hast die Aufmerksamkeit der Spam-Protection auf dich gezogen, bitte unterlasse das Flooden.");

        else if(GetPVarInt(playerid, "CommandSpam") == 8) {
            format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Spamming.", GetName(playerid), playerid);
            SendClientMessageToAll(COLOR_RED, string);
            CallRemoteFunction("KickIncrease", "d", playerid);
            Kick(playerid);
        }
    }

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_WHITE, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(GetPVarInt(playerid, "PlayerMuted") == 1)                                return SendClientMessage(playerid, COLOR_WHITE, "Du wurdest stumm gestellt.");
    return true;
}


public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success) SendClientMessage(playerid, COLOR_RED, "* SERVER: Dieser Befehl ist nicht vorhanden.");
    return true;
}


public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    return true;
}


public OnPlayerExitVehicle(playerid, vehicleid)
{
    return true;
}


public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) {
		new vehicle = GetPlayerVehicleID(playerid);
		
		// faction cars query

		if(IsACar(vehicle) && pStats[playerid][pLicenseCar] == -1) 																		SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Führerschein. Hüte dich vor der Polizei!");
		else if(IsAMotorBike(vehicle) && pStats[playerid][pLicenseBike] == -1)															SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Motorradführerschein. Hüte dich vor der Polizei!");
		else if(IsAPlane(vehicle) && pStats[playerid][pLicenseAir] == -1 || IsAHeli(vehicle) && pStats[playerid][pLicenseAir] == -1)	SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Flugschein. Hüte dich vor der Polizei!");
	}
    return true;
}


public OnPlayerEnterCheckpoint(playerid)
{
    return true;
}


public OnPlayerLeaveCheckpoint(playerid)
{
    return true;
}


public OnPlayerEnterRaceCheckpoint(playerid)
{
    return true;
}


public OnPlayerLeaveRaceCheckpoint(playerid)
{
    return true;
}


public OnRconCommand(cmd[])
{
    return true;
}


public OnPlayerRequestSpawn(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;
    return true;
}


public OnObjectMoved(objectid)
{
    return true;
}


public OnPlayerObjectMoved(playerid, objectid)
{
    return true;
}


public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == pickupHospitalLow && pStats[playerid][pFaction] == 2) {
		SetPlayerPos(playerid, 1163.4342, -1346.5427, 26.6535);
		SetPlayerFacingAngle(playerid, 175.6219);
	}
	if(pickupid == pickupHospitalUp) {
		SetPlayerPos(playerid, 1178.3900, -1325.5103, 14.1177);
		SetPlayerFacingAngle(playerid, 270.7078);
	}
	if(pickupid == pickupParlamentOut) {
        // interior
	}
	if(pickupid == pickupParlamentIn) {
		SetPlayerPos(playerid, 1310.3148, -1370.3049, 13.5740);
		SetPlayerFacingAngle(playerid, 179.4625);
	}
	
	if(pickupid == pickupStoreOut) {
		// interior
	}
	if(pickupid == pickupStoreIn) {
		SetPlayerPos(playerid, 1467.9811, -1174.0726, 23.9470);
		SetPlayerFacingAngle(playerid, 41.0391);
	}
	
    return true;
}


public OnVehicleMod(playerid, vehicleid, componentid)
{
    return true;
}


public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    return true;
}


public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    return true;
}


public OnPlayerSelectedMenuRow(playerid, row)
{
    return true;
}


public OnPlayerExitedMenu(playerid)
{
    return true;
}


public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    return true;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    return true;
}


public OnRconLoginAttempt(ip[], password[], success)
{
    return true;
}


public OnPlayerUpdate(playerid)
{
    return true;
}


public OnPlayerStreamIn(playerid, forplayerid)
{
    return true;
}


public OnPlayerStreamOut(playerid, forplayerid)
{
    return true;
}


public OnVehicleStreamIn(vehicleid, forplayerid)
{
    return true;
}


public OnVehicleStreamOut(vehicleid, forplayerid)
{
    return true;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid) {
        case PLAYER_DIALOG_LOGIN:   // login
        {
            if(!response) Kick(playerid);
            else if(strlen(inputtext) < 4 || strlen(inputtext) > 30) ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein Passwort ein.", "Login", " ");

            mysql_GetString("password", "Accounts", "username", GetName(playerid), pStats[playerid][pPassword]);
            if(strcmp(MD5_Hash(inputtext), pStats[playerid][pPassword], true) == 0) {
                if(strlen(motd) != 0) {
                    new string[1024];
                    format(string, sizeof(string), "\r\n%s\r\n", motd);
                    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "MOTD", string, "OK", " ");
                }
                SetPVarInt(playerid, "Authentication", 1);
                SetPVarInt(playerid, "JustLogged", 1);
                SpawnPlayer(playerid);
            }
            else ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein gewähltes Passwort ein.", "Login", "Abbrechen");
        }
		/*case 1: { // registration
		    if(!response) Kick(playerid);
		    else if(strlen(inputtext) < 4 || strlen(inputtext) > 30) ShowPlayerDialog(playerid, PLAYER_DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registration", "Bitte tippe dein gewünschtes Passwort ein.\n[4-30 Zeichen]", "Registration", "Abbrechen");
		    format(query, sizeof(query), "INSERT INTO `Accounts` (username, password) VALUES('%s', '%s')", GetEscName(playerid), inputtext); mysql_query(query); // evtl. noch andere Werte wie IP usw. setzen
		    SetPVarInt(playerid, "JustRegistered", 1);
		    SpawnPlayer(playerid);
		}*/
        case PLAYER_DIALOG_CLICKEDADM:                             // ClickedPlayer(admin)
        {
            //new giveplayerid = GetPVarInt(playerid,"ClickedPlayer");
            if(!response) return false;
            switch(listitem) {
                case 0:
				{
					ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_MENU, DIALOG_STYLE_LIST, "Admin-Menü", "Account\r\nKick\r\nBan\r\nGoto\r\nGethere\r\nFreeze\r\nWarn\r\nMute\r\n", "Auswählen", "Abbrechen");
				}
				case 1:                           // Call
                {
                }
                case 2:                           // SMS
                {
                }
            }
        }
        case PLAYER_DIALOG_CLICKED:   //ClickedPlayer(Player)
        {
            //new giveplayerid = GetPVarInt(playerid,"ClickedPlayer");
            if(!response) return false;
            switch(listitem) {
                case 0:                           // Call
                {
                }
                case 1:                           // SMS
                {
                }
            }
        }
        case PLAYER_DIALOG_CLICKEDADM_MENU:   // adminmenu (kick, ban, ...)
        {
            new string[256];
            new giveplayerid = GetPVarInt(playerid,"ClickedPlayer");
            if(!response) return false;
            if(GetPVarInt(playerid, "AdminDuty") == 0) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_NOTONDUTY);
            switch(listitem) {
				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_ACCOUNT:
				{
	    			if(pStats[playerid][pAdminLevel] < 3)                       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
				    new str[1024], coordstring0[256], coordstring1[256], coordstring2[256], coordstring3[256], coordstring4[256], coordstring5[256];
				    
					format(coordstring0, sizeof(coordstring0), "----------*** %s ***----------", GetName(giveplayerid));
					format(coordstring1, sizeof(coordstring1), "* E-Mail: %s | IP: %s | Logins: %d | AdminLevel: %d | Fraktion: %d", pStats[giveplayerid][pEmail], pStats[giveplayerid][pIPAddress], pStats[giveplayerid][pLogins], pStats[giveplayerid][pAdminLevel], pStats[giveplayerid][pFaction]);
					format(coordstring2, sizeof(coordstring2), "* Cash: %d | CC: %d | Level: %d | Skin: %d | Health: %f | Armor: %d", pStats[giveplayerid][pCash], pStats[giveplayerid][pCC], pStats[giveplayerid][pLevel], pStats[giveplayerid][pSkin],pStats[giveplayerid][pHealth], pStats[giveplayerid][pArmor]);
					format(coordstring3, sizeof(coordstring3), "* Warns: %d | Warning1: %s | Warning2: %s | Warning3: %s", pStats[giveplayerid][pWarns], pStats[giveplayerid][pWarning1], pStats[giveplayerid][pWarning2], pStats[giveplayerid][pWarning3]);
					format(coordstring4, sizeof(coordstring4), "* VehicleID1: %d | VehicleID2: %d | VehicleID3: %d", pStats[giveplayerid][pVeh1], pStats[giveplayerid][pVeh2], pStats[giveplayerid][pVeh3]);
					format(coordstring5, sizeof(coordstring5), "* PosX: %f | PosY: %f | PosZ: %f", pStats[giveplayerid][pPositionX], pStats[giveplayerid][pPositionY], pStats[giveplayerid][pPositionZ]);

					format(str, sizeof(str), "%s\r\n %s\r\n %s\r\n %s\r\n %s\r\n %s\r\n", coordstring0, coordstring1, coordstring2, coordstring3, coordstring4, coordstring5);
					
					ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "Account", str, "OK", " ");
	    			return true;
				}
				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICK:                           // kick
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICKRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Kick", "Abbrechen");
				}
                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_BAN:                           // ban
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_BANRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Ban", "Abbrechen");
                }
                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_GOTO:                           // goto
                {
                    if(pStats[playerid][pAdminLevel] < 2) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
                    new vehicle;
                    new Float:X, Float:Y, Float:Z;
                    if(IsPlayerInAnyVehicle(playerid)) {
                        GetPlayerPos(giveplayerid, X, Y, Z);
                        vehicle = GetPlayerVehicleID(playerid);
                        SetVehiclePos(vehicle, X+2, Y, Z);
                        PutPlayerInVehicle(playerid, vehicle, 0);
                    }
                    else {
                        GetPlayerPos(giveplayerid, X, Y, Z);
                        SetPlayerPos(playerid, X+4, Y, Z);
                    }
                    format(string, sizeof(string), "** Du hast dich zu %s teleportiert.", GetName(giveplayerid));
                    SendClientMessage(playerid, COLOR_PURPLE, string);
                    format(string, sizeof(string), "** Administrator %s hat sich zu dir teleportiert.", GetName(playerid));
                    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

					format(string, sizeof(string), "** Administrator %s hat sich zu %s teleportiert.", GetName(playerid), GetName(giveplayerid));
    				Log2File("admin", string);
                }
                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_GETHERE:                           // gethere
                {
                    new vehicle;
                    new Float:X, Float:Y, Float:Z;
                    if(pStats[playerid][pAdminLevel] < 2)                       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

                    if(IsPlayerInAnyVehicle(giveplayerid)) {
                        GetPlayerPos(playerid, X, Y, Z);
                        vehicle = GetPlayerVehicleID(giveplayerid);
                        SetVehiclePos(vehicle, X+2, Y, Z);
                        PutPlayerInVehicle(giveplayerid, vehicle, 0);
                    }
                    else {
                        GetPlayerPos(playerid, X, Y, Z);
                        SetPlayerPos(giveplayerid, X+2, Y, Z);
                    }
                    format(string, sizeof(string), "** Du wurdest zu Administrator %s teleportiert.", GetName(playerid));
                    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                    format(string, sizeof(string), "** Du hast %s zu dir teleportiert.", GetName(giveplayerid));
                    SendClientMessage(playerid, COLOR_PURPLE, string);
                    
					format(string, sizeof(string), "** Administrator %s hat %s zu sich teleportiert.", GetName(playerid), GetName(giveplayerid));
    				Log2File("admin", string);
                }

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_FREEZE:                           // freeze
                {
                    if(pStats[playerid][pAdminLevel] < 2)                       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

                    if(GetPVarInt(giveplayerid, "PlayerFrozen") == 0) {
                        TogglePlayerControllable(giveplayerid, false);
                        SetPVarInt(giveplayerid, "PlayerFrozen", 1);

                        format(string, sizeof(string), "** Administrator %s hat dich eingefroren.", GetName(playerid));
                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Du hast %s eingefroren", GetName(giveplayerid));
                        SendClientMessage(playerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Administrator %s hat %s eingefroren.", GetName(playerid), GetName(giveplayerid));
                        SendClientMessageToAll(COLOR_PURPLE, string);
    					Log2File("admin", string);
                    }
                    else {
                        TogglePlayerControllable(giveplayerid, true);
                        SetPVarInt(giveplayerid, "PlayerFrozen", 0);

                        format(string, sizeof(string), "** Administrator %s hat dich aufgetaut.", GetName(playerid));
                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Du hast %s aufgetaut", GetName(giveplayerid));
                        SendClientMessage(playerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Administrator %s hat %s aufgetaut.", GetName(playerid), GetName(giveplayerid));
                        SendClientMessageToAll(COLOR_PURPLE, string);
                        Log2File("admin", string);
                    }
                }

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARN:                           // warn
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARNRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Verwarnen", "Abbrechen");
                }

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_MUTE:                           // mute
                {
                    if(GetPVarInt(giveplayerid, "PlayerMuted") == 0) {
                        SetPVarInt(giveplayerid, "PlayerMuted", 1);

                        format(string, sizeof(string), "** Administrator %s hat dich stumm gestellt.", GetName(playerid));
                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Du hast %s stumm gestellt.", GetName(giveplayerid));
                        SendClientMessage(playerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Administrator %s hat %s stumm gestellt.", GetName(playerid), GetName(giveplayerid));
                        SendClientMessageToAll(COLOR_PURPLE, string);
                        Log2File("admin", string);
                        return true;
                    }
                    if(GetPVarInt(giveplayerid, "PlayerMuted") == 1) {
                        SetPVarInt(playerid, "PlayerMuted", 0);

                        format(string, sizeof(string), "** Administrator %s hat dich entstummt.", GetName(playerid));
                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Du hast %s entstummt.", GetName(giveplayerid));
                        SendClientMessage(playerid, COLOR_PURPLE, string);

                        format(string, sizeof(string), "** Administrator %s hat %s entstummt.", GetName(playerid), GetName(giveplayerid));
                        SendClientMessageToAll(COLOR_PURPLE, string);
                        Log2File("admin", string);
                        return true;
                    }
                }
    		}
        }
		case PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICKRSN:   // kick reason
        {
            new string[256], giveplayerid;
            if(!response) return false;
            if(strlen(inputtext) == 0) {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gekickt.", GetName(playerid));
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gekickt.", GetName(playerid), GetName(giveplayerid));
                SendClientMessageToAll(COLOR_PURPLE, string);
            }
            else {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gekickt. Grund: %s", GetName(playerid), inputtext);
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gekickt. Grund: %s", GetName(playerid), GetName(giveplayerid), inputtext);
                SendClientMessageToAll(COLOR_PURPLE, string);
                Log2File("admin", string);
            }
            Kick(giveplayerid);
        }
        case PLAYER_DIALOG_CLICKEDADM_ADMMENU_BANRSN:   // ban reason
        {
            new string[256], giveplayerid;
            if(!response) return false;
            if(strlen(inputtext) == 0) {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gebannt.", GetName(playerid));
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gebannt.", GetName(playerid), GetName(giveplayerid));
                SendClientMessageToAll(COLOR_PURPLE, string);
            }
            else {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gebannt. Grund: %s", GetName(playerid), inputtext);
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gebannt. Grund: %s", GetName(playerid), GetName(giveplayerid), inputtext);
                SendClientMessageToAll(COLOR_PURPLE, string);
                Log2File("admin", string);
            }
            Ban(giveplayerid);
        }
        case PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARNRSN:  // warn reason
        {
            new string[256], giveplayerid;
            if(!response) return false;
            if(GetPVarInt(giveplayerid, "Authentication") != 1)         return SendClientMessage(playerid, COLOR_RED,  ERRORMESSAGE_USER_ID_NOTONLINE);
            pStats[giveplayerid][pWarns] ++;

            if(strlen(inputtext) == 0) {
                /*format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt [%d/3].", GetName(playerid), GetName(giveplayerid), giveplayerid, pStats[giveplayerid][pWarns]);
                SendClientMessageToAll(COLOR_PURPLE, string);
                Log2File("admin", string);*/
                return false;
            }
            else {
                format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt [%d/3]. Grund: %s", GetName(playerid), GetName(giveplayerid), giveplayerid, pStats[giveplayerid][pWarns], inputtext);
                SendClientMessageToAll(COLOR_PURPLE, string);
                Log2File("admin", string);
            }

            if(pStats[giveplayerid][pWarns] == -1) {
                SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 1/3 gestiegen.");
                format(query, sizeof(query), "UPDATE `Accounts` SET `warning1` = '%s' WHERE `username` = '%s'", inputtext, GetName(giveplayerid));
                mysql_query(query);
                pStats[playerid][pWarns] ++;
            }

            else if(pStats[giveplayerid][pWarns] == 1) {
                SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 2/3 gestiegen.");
                format(query, sizeof(query), "UPDATE `Accounts` SET `warning2` = '%s' WHERE `username` = '%s'", inputtext, GetName(playerid));
                mysql_query(query);
            }

            else if(pStats[playerid][pWarns] == 2) {
                format(string, sizeof(string), "** %s [ID: %d] wurde aufgrund von zuvielen Verwarnungen vom Server gebannt.", GetName(giveplayerid), giveplayerid);
                SendClientMessageToAll(COLOR_PURPLE, string);
                format(query, sizeof(query), "UPDATE `Accounts` SET `warning3` = '%s' WHERE `username` = '%s'", inputtext, GetName(playerid));
                mysql_query(query);
                Kick(giveplayerid);
            }
            else SendClientMessage(playerid, COLOR_RED, "* SERVER: Bei dieser Interaktion ist ein Fehler aufgetreten. (Errorcode: #001)");
            SavePlayerAccount(playerid);
        }
    }
    return false;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    SetPVarInt(playerid,"ClickedPlayer", clickedplayerid);
    if(pStats[playerid][pAdminLevel] >= 1) return ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM, DIALOG_STYLE_LIST, "Menü", "Admin-Menü\nAnrufen\nSMS\n", "Login", "Abbrechen");
    else ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKED, DIALOG_STYLE_LIST, "Menü", "Anrufen\nSMS\n", "Auswählen", "Abbrechen");
    return true;
}

public ResetUnusedDBVehicles()
{
	new playerOnline[MAX_PLAYERS];
	foreach(Player, i){
		GetPlayerName(i, playerOnline[i], sizeof(playerOnline));
		//mysql_GetString("owner", "Vehicles", playerOnline[i], pStats[playerid][pPassword]);

		format(query, sizeof(query), "SELECT `owner` FROM `Vehicles` WHERE `username` = '%s'", playerOnline[i]);
		mysql_query(query);
		mysql_store_result();
	}


	//foreach(Player, i) if(IsPlayerInAnyVehicle(i)) VehicleUsed[GetPlayerVehicleID(i)] = true;
    //for(new v = 1; v != MAX_VEHICLES; v++) if(VehicleUsed[v] == false) SetVehicleToRespawn(v);

	//if(IsPlayerInAnyVehicle(i)) VehicleUsed[GetPlayerVehicleID(i)] = true;
    //for(new v = 1; v != MAX_VEHICLES; v++) if(VehicleUsed[v] == false) SetVehicleToRespawn(v);
	return true;
}

public AntiCheat()
{
    new string[128];
    
    foreach(Player, i) {
		if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK) {
			format(string, sizeof(string), "** [ANTI-CHEAT] Warnung: %s [ID: %d] könnte ein Jetpack benutzen.", GetName(i), i);
	        SendAdminMessage(COLOR_RED, string, 0);

			format(string, sizeof(string), "[Jetpack-Warnung]: %s", GetName(i));
		    Log2File("anti-cheat", string);
		}
	    else if(GetPlayerCash(i) < GetPlayerMoney(i)) {
                format(string, sizeof(string), "** [ANTI-CHEAT] Warnung: %s [ID: %d] könnte einen Geldcheat benutzen. (Geld 'erschaffen': $%d)", GetName(i), i, GetPlayerMoney(i));
                SendAdminMessage(COLOR_RED, string, 0);

				format(string, sizeof(string), "[Geld-Warnung]: %s, 'erschaffenes' Geld: $%d", GetName(i), GetPlayerMoney(i));
			    Log2File("anti-cheat", string);

                new const old_money = GetPlayerCash(i);
                ResetPlayerCash(i), GivePlayerCash(i, old_money);
		}
	    /*else if(pStats[playerid][pAdminLevel] < 1) {
	        if(GetPlayerPing(i) > MAX_PING) {
	            format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Maximaler Ping überschritten. (%d, Maximum: %d)", GetName(playerid), playerid, GetPlayerPing(playerid), MAX_PING);
	            SendClientMessageToAll(COLOR_RED, string);
	            Kick(playerid);
	        }
	    }*/
	}
	//print("Anti Cheat tick.");
	return true;
}

public SendAdminMessage(color, string[], requireduty)
{
    foreach(Player, i) {
        if(pStats[i][pAdminLevel] >= 1) {
            if(GetPVarInt(i, "Authentication") == 1) {
                if(requireduty == 1) {
                    if(GetPVarInt(i, "AdminDuty") == 1) SendClientMessage(i, color, string);
                    else return false;
                }
                else if(requireduty == 0) SendClientMessage(i, color, string);
            }
        }
    }
    return true;
}

public NearByMessage(playerid, color, string[])
{
    new Float: PlayerX, Float: PlayerY, Float: PlayerZ;
    foreach(Player, i) {
        if(GetPVarInt(i, "Authentication") == 1) {
            GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
            if(IsPlayerInRangeOfPoint(i, 12, PlayerX, PlayerY, PlayerZ)) {
                if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i)) SendClientMessage(i, color, string);
            }
        }
    }
    return true;
}

public ChangeWeather()
{
	new i;
	for(i = 0; i < 10; i++) i = random(45);
	SetWeather(i);
    return true;
}

public ClearTextSpam(playerid) SetPVarInt(playerid, "TextSpam", 0);
public ClearCommandSpam(playerid) SetPVarInt(playerid, "CommandSpam", 0);


// stocks

stock ResetPlayerVariables(playerid)
{
    pStats[playerid][pAdminLevel]   = -1;
    pStats[playerid][pFaction]      = -1;
    pStats[playerid][pFactionRank]  = -1;
    pStats[playerid][pJob]          = -1;
    pStats[playerid][pCash]         = -1;
    pStats[playerid][pCC]           = -1;
    pStats[playerid][pLevel]        = -1;
    pStats[playerid][pSkin]         = -1;
    pStats[playerid][pHealth]       = -1;
    pStats[playerid][pArmor]        = -1;
    pStats[playerid][pPositionX]    = -1;
    pStats[playerid][pPositionY]    = -1;
    pStats[playerid][pPositionZ]    = -1;
    pStats[playerid][pPositionA]    = -1;
    pStats[playerid][pLogins]       = -1;
    pStats[playerid][pWarns]        = -1;
    pStats[playerid][pWarning1]     = -1;
    pStats[playerid][pWarning2]     = -1;
    pStats[playerid][pWarning3]     = -1;
    pStats[playerid][pVeh1]         = -1;
    pStats[playerid][pVeh2]         = -1;
    pStats[playerid][pVeh3]         = -1;
    pStats[playerid][pLicenseCar]   = -1;
    pStats[playerid][pLicenseBike]  = -1;
    pStats[playerid][pLicenseAir]   = -1;

    SetPVarInt(playerid, "Authentication", 0);
    SetPVarInt(playerid, "LoggingOut", 0);
    SetPVarInt(playerid, "JustLogged", 1);
    SetPVarInt(playerid, "PlayerMuted", 0);

    TogglePlayerSpectating(playerid, false);
    return true;
}


stock mysql_GetString(field[], table[], req[], requirement[], var[])
{
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", field, table, req, requirement); mysql_query(query); mysql_store_result();
    if(mysql_fetch_row(var) == 1) mysql_free_result();
    return true;
}


stock mysql_GetInt(field[], table[], req[], requirement[])
{
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", field, table, req, requirement); mysql_query(query); mysql_store_result();
    new var = mysql_fetch_int(); mysql_free_result();
	//if(var == -1) return false;
    return var;
}


stock Float:mysql_GetFloat(field[], table[], req[], requirement[])
{
    new Float:var;
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", field, table, req, requirement); mysql_query(query); mysql_store_result();
    if(mysql_fetch_float(var) == 1) {
        mysql_free_result();
        return var;
    }
    return 0.0123;
}

stock mysql_GetVehicleString(field[], req[], requirement[], var[])
{
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `Vehicles` WHERE `%s` = '%s'", field, req, requirement); mysql_query(query); mysql_store_result();
    if(mysql_fetch_row(var) == 1) mysql_free_result();
    return true;
}

stock mysql_GetVehicleInt(field[], req[], requirement[])
{
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `Vehicles` WHERE `%s` = '%d'", field, req, requirement); mysql_query(query); mysql_store_result();
    new var = mysql_fetch_int(); mysql_free_result();
	//if(var == -1) return false;
    return var;
}

stock Float:mysql_GetVehicleFloat(field[], req[], requirement)
{
    new Float:var;
    mysql_real_escape_string(field, field); mysql_real_escape_string(req, req); mysql_real_escape_string(requirement, requirement);
    format(query, sizeof(query), "SELECT `%s` FROM `Vehicles` WHERE `%s` = '%d'", field, table, req, requirement); mysql_query(query); mysql_store_result();
    if(mysql_fetch_float(var) == 1) {
        mysql_free_result();
        return var;
    }
    return 0.0123;
}


stock LoadPlayerAccount(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;

    mysql_GetString("email",        "Accounts", "username", GetName(playerid), pStats[playerid][pEmail]);
    mysql_GetString("ip_address",   "Accounts", "username", GetName(playerid), pStats[playerid][pIPAddress]);

    pStats[playerid][pAdminLevel]   = mysql_GetInt("admin_level",   "Accounts", "username", GetName(playerid));
    pStats[playerid][pFaction]      = mysql_GetInt("faction",       "Accounts", "username", GetName(playerid));
    pStats[playerid][pFactionRank]  = mysql_GetInt("faction_rank",  "Accounts", "username", GetName(playerid));
    pStats[playerid][pJob]          = mysql_GetInt("job",           "Accounts", "username", GetName(playerid));
    pStats[playerid][pCash]         = mysql_GetInt("cash",          "Accounts", "username", GetName(playerid));
    pStats[playerid][pCC]           = mysql_GetInt("cc",            "Accounts", "username", GetName(playerid));
    pStats[playerid][pLevel]        = mysql_GetInt("level",         "Accounts", "username", GetName(playerid));
    pStats[playerid][pSkin]         = mysql_GetInt("skin",          "Accounts", "username", GetName(playerid));

    pStats[playerid][pHealth]       = mysql_GetFloat("health",      "Accounts", "username", GetName(playerid));
    pStats[playerid][pArmor]        = mysql_GetFloat("armor",       "Accounts", "username", GetName(playerid));
    pStats[playerid][pPositionX]    = mysql_GetFloat("position_X",  "Accounts", "username", GetName(playerid));
    pStats[playerid][pPositionY]    = mysql_GetFloat("position_Y",  "Accounts", "username", GetName(playerid));
    pStats[playerid][pPositionZ]    = mysql_GetFloat("position_Z",  "Accounts", "username", GetName(playerid));
    pStats[playerid][pPositionA]    = mysql_GetFloat("position_A",  "Accounts", "username", GetName(playerid));

    pStats[playerid][pLogins]       = mysql_GetInt("logins",        "Accounts", "username", GetName(playerid));
    pStats[playerid][pWarns]        = mysql_GetInt("warns",         "Accounts", "username", GetName(playerid));

    mysql_GetString("warning1",     "Accounts", "username", GetName(playerid), pStats[playerid][pWarning1]);
    mysql_GetString("warning2",     "Accounts", "username", GetName(playerid), pStats[playerid][pWarning2]);
    mysql_GetString("warning3",     "Accounts", "username", GetName(playerid), pStats[playerid][pWarning3]);

    pStats[playerid][pVeh1]         = mysql_GetInt("vehicleID1",    "Accounts", "username", GetName(playerid));
    pStats[playerid][pVeh2]         = mysql_GetInt("vehicleID2",    "Accounts", "username", GetName(playerid));
    pStats[playerid][pVeh3]         = mysql_GetInt("vehicleID3",    "Accounts", "username", GetName(playerid));
    pStats[playerid][pLicenseCar]   = mysql_GetInt("license_car",   "Accounts", "username", GetName(playerid));
    pStats[playerid][pLicenseBike]  = mysql_GetInt("license_bike",  "Accounts", "username", GetName(playerid));
    pStats[playerid][pLicenseAir]   = mysql_GetInt("license_air",   "Accounts", "username", GetName(playerid));

    pStats[playerid][pLogins] ++;

    ResetPlayerCash(playerid);
    GivePlayerCash(playerid,            pStats[playerid][pCash]);
    SetPlayerScore(playerid,            pStats[playerid][pLevel]);
    SetPlayerSkin(playerid,             pStats[playerid][pSkin]);
    SetPlayerHealth(playerid,           pStats[playerid][pHealth] + 1);
    SetPlayerArmour(playerid,           pStats[playerid][pArmor]);
    SetPlayerPos(playerid,              pStats[playerid][pPositionX], pStats[playerid][pPositionY], pStats[playerid][pPositionZ] + 3);
    SetPlayerFacingAngle(playerid,      pStats[playerid][pPositionA]);

    SetPlayerColor(playerid, COLOR_WHITE);
    SavePlayerAccount(playerid);                  // IP-Save

	SetPlayerMapIcon(playerid, 0, 1172.0768, -1321.5231, 15.3990, 22, 1); // Hospital
    return true;
}


stock SavePlayerAccount(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;

    if(GetPVarInt(playerid, "LoggingOut") == 0) GetPlayerIp(playerid, pStats[playerid][pIPAddress], 17);
    pStats[playerid][pCash]         = GetPlayerCash(playerid);
    pStats[playerid][pSkin]         = GetPlayerSkin(playerid);
    GetPlayerHealth(playerid,       pStats[playerid][pHealth]);
    GetPlayerArmour(playerid,       pStats[playerid][pArmor]);
    GetPlayerPos(playerid,          pStats[playerid][pPositionX], pStats[playerid][pPositionY], pStats[playerid][pPositionZ]);
    GetPlayerFacingAngle(playerid,  pStats[playerid][pPositionA]);
    
    format(query, sizeof(query), "UPDATE accounts SET ip_address = '%s', admin_level = '%d', faction = '%d', faction_rank = '%d', job = '%d', cash = '%d', cc = '%d', level = '%d', skin = '%d', health = '%f', armor = '%f', position_X = '%f', position_Y = '%f', position_Z = '%f', position_A = '%f', logins = '%d', warns = '%d' WHERE username='%s'",
	pStats[playerid][pIPAddress],
	pStats[playerid][pAdminLevel],
	pStats[playerid][pFaction],
	pStats[playerid][pFactionRank],
	pStats[playerid][pJob],
	pStats[playerid][pCash],
	pStats[playerid][pCC],
	pStats[playerid][pLevel],
	pStats[playerid][pSkin],
	pStats[playerid][pHealth],
	pStats[playerid][pArmor],
	pStats[playerid][pPositionX],
	pStats[playerid][pPositionY],
	pStats[playerid][pPositionZ],
	pStats[playerid][pPositionA],
	pStats[playerid][pLogins],
	pStats[playerid][pWarns],
	GetEscName(playerid)
	);
    mysql_query(query);
    //REST DANN OBEN HINZUFÜGEN FALLS GEBRAUCHT
/*	format(query, sizeof(query), "UPDATE `Accounts` SET `warning1` 		= '%s' WHERE `username` = '%s'", pStats[playerid][pWarning1],	GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `warning2` 		= '%s' WHERE `username` = '%s'", pStats[playerid][pWarning2],	GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `warning3` 		= '%s' WHERE `username` = '%s'", pStats[playerid][pWarning3],	GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `vehicleID1`	= '%d' WHERE `username` = '%s'", pStats[playerid][pVeh1],      GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `vehicleID2`	= '%d' WHERE `username` = '%s'", pStats[playerid][pVeh2],      GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `vehicleID3`	= '%d' WHERE `username` = '%s'", pStats[playerid][pVeh3],      GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `license_car` 	= '%d' WHERE `username` = '%s'", pStats[playerid][pLicenseCar],  GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `license_bike`	= '%d' WHERE `username` = '%s'", pStats[playerid][pLicenseBike],GetEscName(playerid)); mysql_query(query);
    format(query, sizeof(query), "UPDATE `Accounts` SET `license_air` 	= '%d' WHERE `username` = '%s'", pStats[playerid][pLicenseAir], GetEscName(playerid)); mysql_query(query);*/

    return true;
}


stock LoadVehiclesFromDatabase()
{
    mysql_query("SELECT COUNT(*) FROM `Vehicles`"); mysql_store_result();
	new count = mysql_fetch_int(); mysql_free_result();


/*
	vVehicleID,
    vOwner,
    vModelID,
    Float: vPositionX,
    Float: vPositionY,
    Float: vPositionZ,
    Float: vPositionA,
    vColor1,
    vColor2
*/
	new idx = 0;
	new Float:X, Float:Y, Float:Z, Float:A;
	new owner[128], model, color1, color2;
	
	for(new i = 0; i < count; i++) {
		format(query, sizeof(query), "SELECT `owner` FROM `Vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 		if(mysql_fetch_row(owner) == 1) mysql_free_result();
		format(query, sizeof(query), "SELECT `model` FROM `Vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  	model = mysql_fetch_int(); mysql_free_result();
		format(query, sizeof(query), "SELECT `position_X` FROM `Vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(X) == 1) mysql_free_result();
		format(query, sizeof(query), "SELECT `position_Y` FROM `Vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(Y) == 1) mysql_free_result();
 		format(query, sizeof(query), "SELECT `position_Z` FROM `Vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(Z) == 1) mysql_free_result();
		format(query, sizeof(query), "SELECT `position_A` FROM `Vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(A) == 1) mysql_free_result();
		format(query, sizeof(query), "SELECT `color1` FROM `Vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  color1 = mysql_fetch_int(); mysql_free_result();
		format(query, sizeof(query), "SELECT `color2` FROM `Vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  color2 = mysql_fetch_int(); mysql_free_result();

    	AddStaticVehicle(model, X, Y, Z, A, color1, color2);
		//Vehicles[vehicleid][pVeh1]  = mysql_GetVehicleFloat("position_X", "vehicleID", i);
		idx++;
		
		printf("Owner: %s, Model: %d, X: %f, Y: %f, Z: %f, A: %f, Color1: %d, Color2: %d", owner, model, X, Y, Z, A, color1, color2);
	}


    //format(query, sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", field, table, req, requirement); mysql_query(query); mysql_store_result();
	/*
    new index;
    mysql_query("SELECT * FROM `Vehicles`");
    mysql_store_result();
    if(mysql_num_rows() > 0) {
        while(mysql_fetch_row(query)) {
            sscanf(query, "e<p<|>dffffdd>", Vehicles[index]);
            CreateVehicle(Vehicles[index][vModelID], Vehicles[index][vPositionX], Vehicles[index][vPositionY], Vehicles[index][vPositionZ], Vehicles[index][vPositionZ], Vehicles[index][vColor1], Vehicles[index][vColor2], -1);
            index++;
        }
    }
    mysql_free_result();
	*/
	

/*
	vVehicleID,
    vOwner,
    vModelID,
    Float: vPositionX,
    Float: vPositionY,
    Float: vPositionZ,
    Float: vPositionA,
    vColor1,
    vColor2
    

	new Color1, Color2, Float:PositionX, Float:PositionY, Float:PositionZ, Float:AngleZ;
    new vehicleid = GetPlayerVehicleID(playerid);
    new ModelID = GetVehicleModel(vehicleid);

    if(pStats[playerid][pAdminLevel] < 3)										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerInAnyVehicle(playerid))											return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);

    GetVehiclePos(vehicleid, PositionX, PositionY, PositionZ);
    GetVehicleZAngle(vehicleid, AngleZ);
	GetVehicleColor(vehicleid, Color1, Color2);

	format(query, sizeof(query), "INSERT INTO `Vehicles` (model, position_X, position_Y, position_Z, angle, color1, color2) VALUES(%d, %f, %f, %f, %f, %d, %d)", ModelID, PositionX, PositionY, PositionZ, AngleZ, Color1, Color2);
	mysql_query(query);

*/

/*	foreach(Player, i)
	
	for(new i = 0; i < MAX_VEHICLES; i++) {
		Vehicles[
	    mysql_query("SELECT position_X FROM `Vehicles` WHERE `owner` = "%s", );
	}



*/
	printf("\n* SERVER: Loaded %d MySQL vehicles successfully.", idx);
    return true;
}

stock IsACar(carid)
{
	if(!IsABike(carid) && !IsAMotorBike(carid) && !IsAPlane(carid) && !IsAHeli(carid) && !IsABoat(carid) /*&& !IsATruck(carid)*/) return true;
	return false;
}

stock IsABike(carid)
{
	new modelid = GetVehicleModel(carid);
	if(modelid == 509 || modelid == 481 || modelid == 510) return true;
	return false;
}

stock IsAMotorBike(carid)
{
	new modelid = GetVehicleModel(carid);
	if(modelid == 522 || modelid == 462 || modelid == 521 || modelid == 461 || modelid == 463 || modelid == 581 || modelid == 448 || modelid == 586 || modelid == 523 || modelid == 468 || modelid == 471) return true;
	return false;
}

stock IsAPlane(carid)
{
 	new modelid = GetVehicleModel(carid);
	if(modelid == 592 || modelid == 577 || modelid == 511 || modelid == 512  || modelid == 593 || modelid == 520 || modelid == 553 || modelid == 476 || modelid == 519 || modelid == 460 || modelid == 513 || modelid == 548 || modelid == 425  || modelid == 417  || modelid == 487  || modelid == 488  || modelid == 497 || modelid == 563 || modelid == 447  || modelid == 469) return true;
	return false;
}

stock IsAHeli(carid)
{
 	new modelid = GetVehicleModel(carid);
 	if(modelid == 548 || modelid == 425 || modelid == 417 || modelid == 487 || modelid == 488 || modelid == 497 || modelid == 563 || modelid == 447 || modelid == 469) return true;
	return false;
}

stock IsABoat(carid)
{
	new modelid = GetVehicleModel(carid);
	if(modelid == 430 || modelid == 446 || modelid == 452 || modelid == 453 || modelid == 454 || modelid == 472 || modelid == 473 || modelid == 484 || modelid == 493 || modelid == 539 || modelid == 595) return true;
	return false;
}

stock IsATruck(carid)
{
	new modelid = GetVehicleModel(carid);
	if(modelid == 440 || modelid == 456 || modelid == 403) return true;
	return false;
}

stock Log2File(filename[], string[])
{
	new str[256], str2[256];
	new year, month, day, hour, minute, second;

	getdate(year, month, day);
	gettime(hour, minute, second);
	
    format(str, sizeof(str), "[%d:%d:%d]: %s\r\n", hour, minute, second, string);
    format(str2, sizeof(str2), "logs/%d-%d-%d-%s.log", year, month, day, filename);

    new File:hFile;
    hFile = fopen(str2, io_append);
    fwrite(hFile, str);
    fclose(hFile);
}

stock String2Integer(string)
{
	new str[50];
	format(str, sizeof(str), "%d", string);
	return str;
}

stock GetEscName(playerid)
{
    new EscapedName[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) {
        GetPlayerName(playerid, name, sizeof(name));
        mysql_real_escape_string(name, EscapedName);
    }
    else EscapedName = "Unknown";
    return EscapedName;
}

stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) GetPlayerName(playerid, name, sizeof(name));
    else name = "Unknown";
    return name;
}

stock GetNameEx(playerid)
{
    new str[24], String[128];
    GetPlayerName(playerid, String, 24);
    strmid(str, String, 0, strlen(String), 24);
    for(new i = 0; i < MAX_PLAYER_NAME; i++) if (str[i] == '_') str[i] = ' ';
    return str;
}

