/*

-* 		 samp2k13 roleplay gamemode
-* 	   created by Harti aka. surrender
-*  credits to RealCop228 & the GRX server

*/


#include <a_samp>
#include <a_mysql>
#include <sscanf2>
#include <YSI\y_commands>
#include <YSI\y_master>
#include <foreach>
#include <hash>
#include <samp2k13>


#define SERVER_VERSION          "1.0.0" // maj 1, ver 0, rev 0

#define MYSQL_HOST              "db4free.net"
#define MYSQL_USER              "samp2k13"
#define MYSQL_DB                "samp2013"
#define MYSQL_PASS              "db123456"
#define MYSQL_DBHANDLE          1
                  
#define GivePlayerCash(%0,%1)   SetPVarInt(%0,"Money", GetPlayerCash(%0)+%1), GivePlayerMoney(%0,%1) // ServerSide Money (credits to Luka P.)
#define ResetPlayerCash(%0)     SetPVarInt(%0,"Money", 0), ResetPlayerMoney(%0)
#define GetPlayerCash(%0)       GetPVarInt(%0,"Money")

#define ERRORMESSAGE_ADMIN_CMD          "** Dein AdminLevel ist dafür zu niedrig."
#define ERRORMESSAGE_ADMIN_NOTONDUTY    "** Du bist nicht On-Duty."
#define ERRORMESSAGE_NOVEHICLE			"** Du bist in keinem Vehikel."
#define ERRORMESSAGE_USER_NOTLOGGEDIN   "* Du bist nicht eingeloggt."
#define ERRORMESSAGE_USER_ID_NOTONLINE  "* Dieser Spieler ist nicht online bzw. eingeloggt."
#define ERRORMESSAGE_FACTIONRANK_TOOLOW "* Dein Fraktionsrang ist dafür zu niedrig."
#define ERRORMESSAGE_WRONG_FACTION      "* Du bist in der falschen Fraktion."

#define CARMENU 25000
#define MAX_PING 550

#define COLOR_WHITE     0xFFFFFFFF                // standard
#define COLOR_GREY      0xAFAFAFFF                // usage messages
#define COLOR_PURPLE    0xC2A2DADD                // admin messages
#define COLOR_RED       0xAA333333                // error messages
#define COLOR_OOC       0xFF9900AA                // ooc messages
#define COLOR_LIGHTBLUE 0x1464F4FF                // me/do messages

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


// custom callbacks
forward _OnMySQLConfigurationLoad();
forward _OnMySQLPlayerDataSave(playerid);
forward _OnMySQLPlayerDataLoad(playerid);
forward _OnMySQLVehicleDataSave(vehicleid);
forward _OnMySQLVehicleDataLoad();
forward _OnPlayerDataAssign(playerid);
forward _OnAntiCheatTick();
forward _OnWeatherChange(weatherid);
forward _OnObjectsCreate();
forward _OnPlayerObjectsCreate(playerid);

// custom functions
forward _sendAdminMessage(color, string[], requireduty);
forward _sendFactionMessage(color, string[], factionid);
forward _sendNearByMessage(playerid, Float:extraRadius, string[]);
forward _setPlayerDuty(playerid, bool:status);
forward _resetPlayerDataArray(playerid);
forward _resetTazerAvailability(playerid);
forward _unfreezePlayer(playerid);
forward _clearTextSpam(playerid);
forward _clearCommandSpam(playerid);


enum ConfigurationData
{
	//configID,
	motd[256],
	taxes,
	faction_1_funds,
	faction_2_funds,
	faction_3_funds,
	faction_4_funds,
	faction_5_funds
};
new sConfig[ConfigurationData];

enum PlayerData
{
    pUsername[MAX_PLAYER_NAME + 1],
    pPassword[64 + 1],
    pEmail[128 + 1],
    pIPAddress[16 + 1],
	pJustRegistered,
    pAdminLevel,
    pFaction,
    pFactionRank,
	pDuty,
    pWantedLevel,
    pJob,
    pCash,
    pBank,
    pLevel,
    pSkin,
    Float: pHealth,
    Float: pArmor,
    Float: pPosX,
    Float: pPosY,
    Float: pPosZ,
    Float: pPosA,
    pLogins,
    pWarns,
    pWarning1[128 + 1],
    pWarning2[128 + 1],
    pWarning3[128 + 1],
    pBanstamp,
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
    vPlate[8 + 1],
    vVehicleID,
    vOwner[MAX_PLAYER_NAME + 1],
    vModelID,
    Float: vHealth,
    vPanelDamage[13 + 1],
    vDoorDamage[11 + 1],
    vLightDamage[7 + 1],
    vTireDamage[7 + 1],
    Float: vPosX,
    Float: vPosY,
    Float: vPosZ,
    Float: vPosA,
    vColor1,
    vColor2,
    vNavigation,
    vLocked,
    vFuel,
    vFilled
    //vehicle mods
};
new vVehicles[MAX_VEHICLES][VehicleData]; // MAX_VEHICLES currently 2000 (0.3x)
new vTotal; // total vehicles in db, filled @_OnMySQLVehicleDataLoad()

new querystring[715];
new CurrentSpawnedVehicle[MAX_PLAYERS];
new pickupHospitalLow, pickupHospitalUp, pickupParlamentOut, pickupParlamentIn;
new pickupStoreOut, pickupStoreIn;


//------------------------------------------------------------------------------ STANDARD CALLBACKS


main() {}


public OnGameModeInit()
{
    mysql_debug(1);
    mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);
	mysql_set_charset("latin1_german1_ci");
	mysql_function_query(MYSQL_DBHANDLE, "SELECT * FROM `configuration`", true, "_OnMySQLConfigurationLoad", "");
	mysql_function_query(MYSQL_DBHANDLE, "SELECT * FROM `vehicles` ORDER BY `vehicleid` ASC", true, "_OnMySQLVehicleDataLoad", "");

    foreach(Player, i) OnPlayerConnect(i);
    SetTimer("_OnWeatherChange", 2700007, true); // 45min
	SetTimer("_OnAntiCheatTick", 5003, true);

    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    LimitGlobalChatRadius(20.0);
	LimitPlayerMarkerRadius(300.0);
	//ManualVehicleEngineAndLights();
    SetGameModeText("samp2k13");
    SetNameTagDrawDistance(20.0);
    ShowNameTags(1);
	ShowPlayerMarkers(0);
    UsePlayerPedAnims();

	_OnObjectsCreate();

    Command_AddAltNamed("adminduty", "aduty"); // short forms for cmds
    Command_AddAltNamed("ooc", "o");
    Command_AddAltNamed("announce", "ann");
    Command_AddAltNamed("adminchat", "a");
    Command_AddAltNamed("radio", "r");
    
/*	AddStaticVehicle(416,1178.0715,-1308.3512,14.0024,269.4829,1,0);	// Krankenwagen1
	AddStaticVehicle(416,1178.0037,-1338.9781,14.0427,271.4690,1,0); 	// Krankenwagen2                ---- DB !
	AddStaticVehicle(416,1123.5791,-1328.7023,13.4239,0.3476,1,0); 		// Krankenwagen3(hinten)
	AddStaticVehicle(563,1161.8552,-1377.1299,27.3177,268.7520,1,0); 	// Helikopter*/
	
	pickupHospitalLow = CreatePickup(1318, 1, 1172.0779, -1325.4570, 15.4076, -1);
	pickupHospitalUp  = CreatePickup(1318, 1, 1163.7961, -1342.8069, 26.6160, -1);
	pickupParlamentOut = CreatePickup(1318, 1, 1310.0339, -1367.0052, 13.5151, -1);
	//pickupParlamentIn =
	pickupStoreOut = CreatePickup(1318, 1, 1471.2391, -1177.9728, 23.9215, -1);
	//pickupStoreIn = CreatePickup(1318, 1, 1471.2391, -1177.9728, 23.9215, -1);

	Create3DTextLabel("Krankenhausdach", COLOR_WHITE, 1172.0779, -1325.4570, 90.0, -1, 0);
	Create3DTextLabel("Parlament", COLOR_WHITE, 1310.0339, -1367.0052, 353.0, -1, 0);
	Create3DTextLabel("Store", COLOR_WHITE, 1471.2391, -1177.9728, 23.9215, 221.0, -1, 0);
	
 	AddPlayerClass(0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0); // ( http://forum.sa-mp.com/showthread.php?t=269488 )
    return true;
}


public OnGameModeExit()
{
    foreach(Player, i) {
		_OnMySQLPlayerDataSave(i);
		OnPlayerDisconnect(i, 2);
	}

	for(new i = 0; i < 10; i++) _OnMySQLVehicleDataSave(i);
    mysql_close();
    return true;
}


public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid); // disables class selection
    return true;
}


public OnPlayerConnect(playerid)
{
    new string[128];
    
    _resetPlayerDataArray(playerid);
    _clearChat(playerid);
	
	format(querystring, sizeof(querystring), "SELECT * FROM `accounts` WHERE `username` = '%s'", _getEscName(playerid));
	mysql_function_query(MYSQL_DBHANDLE, querystring, true, "_OnMySQLPlayerDataLoad", "i", playerid); // login procedure

	format(string, sizeof(string), "* %s [ID: %d] hat den Server betreten.", _getName(playerid), playerid);
	SendClientMessageToAll(COLOR_OOC, string);
	
	_OnPlayerObjectsCreate(playerid);
    return true;
}


public OnPlayerDisconnect(playerid, reason)
{
    new string[128];
    
    switch(reason) {
        case 0: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen. [Timeout]", _getName(playerid), playerid);
        case 1,2: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen.", _getName(playerid), playerid);
        //case 2: format(string, sizeof(string), "* %s [ID: %d] hat den Server verlassen. [Kicked/Banned]",   _getName(playerid), playerid);
    }
    SendClientMessageToAll(COLOR_OOC, string);

    if(reason == 1 && GetPVarInt(playerid, "Authentication") == 1) {
        SetPVarInt(playerid, "LoggingOut", 1);
        _OnMySQLPlayerDataSave(playerid);
    }
    return true;
}


public OnPlayerSpawn(playerid)
{
    if(pStats[playerid][pJustRegistered] == 1) {
		pStats[playerid][pJustRegistered] = 0;
		SetPVarInt(playerid, "JustLogged", 1);
		
        GivePlayerCash(playerid, 100);
        SetPlayerScore(playerid, 1);
        SetPlayerSkin(playerid, random(299));
        SetPlayerPos(playerid, -2706.5261, 397.7129, 4.3672);

		format(querystring, sizeof(querystring), "UPDATE `accounts` SET `justRegistered` = '0' WHERE `username` = '%s'", _getEscName(playerid));
		mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");

        _OnMySQLPlayerDataSave(playerid);
        return true;
    }
    
    if(GetPVarInt(playerid, "JustLogged") == 1) {
        SetPVarInt(playerid, "JustLogged", 0);

		new string[128];
		format(string, sizeof(string), "* Willkommen auf dem samp2k13 Server (%s).", SERVER_VERSION);
        SendClientMessage(playerid, COLOR_OOC, string);

        _OnPlayerDataAssign(playerid);
        _OnMySQLPlayerDataSave(playerid); // IP-Save
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

	_OnPlayerDataAssign(playerid);

	switch(pStats[playerid][pFaction]) {
		case 1: { // Polizei
		    if(pStats[playerid][pDuty] == 1) {
				SetPlayerHealth(playerid, 100.0);
				SetPlayerArmour(playerid, 100.0);
				GivePlayerWeapon(playerid, 24, 50); // deagle
				SetPlayerSkillLevel(playerid, 2, 500);
		        SetPVarInt(playerid, "TazerAvailable", 1);

				switch(pStats[playerid][pFactionRank]) {
					case 1: 	SetPlayerSkin(playerid, 280);
					case 2,3:   SetPlayerSkin(playerid, 281);
					case 4:		SetPlayerSkin(playerid, 282);
					case 5:     SetPlayerSkin(playerid, 283);
				}
			}
		}

		case 2: { // Arzt
		    if(pStats[playerid][pDuty] == 1) {
				SetPlayerHealth(playerid, 100.0);

				switch(pStats[playerid][pFactionRank]) {
					case 1: 	SetPlayerSkin(playerid, 275);
					case 2,3:   SetPlayerSkin(playerid, 274);
					case 4:		SetPlayerSkin(playerid, 276);
					case 5:     SetPlayerSkin(playerid, 70);
				}
			}
		}

		case 3: { // Fahrschule
			SetPlayerPos(playerid, -1606.4093, 673.4142, -5.2422); // 0
			SetPlayerFacingAngle(playerid, 180.1302);

			switch(pStats[playerid][pFactionRank]) {
				//case 1: 	SetPlayerSkin(playerid, 275);
				//case 2,3:   SetPlayerSkin(playerid, 274);
				case 4:		SetPlayerSkin(playerid, 240);
				case 5:     SetPlayerSkin(playerid, 147);
			}
		}

		case 4: { // ADAC
			SetPlayerPos(playerid, -1606.4093, 673.4142, -5.2422); // 0
			SetPlayerFacingAngle(playerid, 359.0151);

		}

		case 5: { // Taxi
			SetPlayerPos(playerid, -1977.5164, 102.5072, 27.6875);
			SetPlayerFacingAngle(playerid, 88.0719);

		}
	}
    return true;
}


public OnPlayerDeath(playerid, killerid, reason)
{
    SetPVarInt(playerid, "JustDied", 1);
	pStats[playerid][pDuty] = 0;
	TogglePlayerSpectating(playerid, false);
    return true;
}


public OnVehicleSpawn(vehicleid)
{
	for(new i = 0; i < 10; i++)	if(vehicleid != vVehicles[i][vVehicleID]) DestroyVehicle(vehicleid);
	return true;
}

public OnVehicleDeath(vehicleid, killerid)
{
	format(querystring, sizeof(querystring), "DELETE FROM `vehicles` WHERE `plate` = '%s'", vVehicles[vehicleid][vPlate]);
	mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");
	return true;
}


public OnPlayerText(playerid, text[])
{
    new string[128];
    
    if(GetPVarInt(playerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, "* Du musst eingeloggt sein um sprechen zu können.");

    /*SetPVarInt(playerid, "TextSpam", GetPVarInt(playerid, "TextSpam") + 1);
    SetTimerEx("ClearTextSpam", 2000, false, "d", playerid);

    if(GetPVarInt(playerid,"TextSpam") == 15) {
        format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Spamming.", _getName(playerid), playerid);
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
	format(string, sizeof(string), "%s: %s", _getName(playerid), text);

	_sendNearByMessage(playerid, 1.0, string);
	SetPlayerChatBubble(playerid, text, COLOR_WHITE, 8.0, 4000);

	format(string, sizeof(string), "[SAY] %s: %s", _getName(playerid), text);
    _logToFile("chat", string);
    return false;
}


public OnPlayerCommandReceived(playerid, cmdtext[])
{
    new string[128];

    if(pStats[playerid][pAdminLevel] < 1) {
        SetPVarInt(playerid, "CommandSpam", GetPVarInt(playerid, "CommandSpam") + 1);
        SetTimerEx("ClearCommandSpam", 1000, false, "d", playerid);

        if(GetPVarInt(playerid, "CommandSpam") > 5)     return SendClientMessage(playerid, COLOR_RED, "* SERVER: Du hast die Aufmerksamkeit der Spam-Protection auf dich gezogen, bitte unterlasse das Flooden.");

        else if(GetPVarInt(playerid, "CommandSpam") == 8) {
            format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Spamming.", _getName(playerid), playerid);
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


public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) return true;
public OnPlayerExitVehicle(playerid, vehicleid) return true;


public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) {
		new vehicle = GetPlayerVehicleID(playerid);
		
		// faction cars query

		if(_getVehicleType(vehicle) == 0 && pStats[playerid][pLicenseCar] != 1) 														SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Führerschein. Hüte dich vor der Polizei!");
		//else if(_getVehicleType(vehicle) == 1 && pStats[playerid][pLicenseTruck] != 1) 												SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen LKW-Führerschein. Hüte dich vor der Polizei!");
		else if(_getVehicleType(vehicle) == 3 && pStats[playerid][pLicenseBike] != 1)													SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Motorradführerschein. Hüte dich vor der Polizei!");
		else if(_getVehicleType(vehicle) == 5 && pStats[playerid][pLicenseAir] != 1 || _getVehicleType(vehicle) == 9 && pStats[playerid][pLicenseAir] == -1)
																																		SendClientMessage(playerid, COLOR_WHITE, "* Du besitzt keinen gültigen Flugschein. Hüte dich vor der Polizei!");
	}
    return true;
}


public OnPlayerEnterCheckpoint(playerid) return true;
public OnPlayerLeaveCheckpoint(playerid) return true;
public OnPlayerEnterRaceCheckpoint(playerid) return true;
public OnPlayerLeaveRaceCheckpoint(playerid) return true;
public OnRconCommand(cmd[]) return true;


public OnPlayerRequestSpawn(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;
    return true;
}


public OnObjectMoved(objectid) return true;
public OnPlayerObjectMoved(playerid, objectid) return true;


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


public OnVehicleMod(playerid, vehicleid, componentid) return true;
public OnVehiclePaintjob(playerid, vehicleid, paintjobid) return true;
public OnVehicleRespray(playerid, vehicleid, color1, color2) return true;
public OnPlayerSelectedMenuRow(playerid, row) return true;
public OnPlayerExitedMenu(playerid) return true;
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) return true;


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	#define PRESSED(%0) \
	    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

				// N
	if(PRESSED(KEY_NO) && pStats[playerid][pFaction] == 1 && pStats[playerid][pDuty] == 1 && GetPlayerWeapon(playerid) == 0) {
		new giveplayerid = GetPlayerTargetPlayer(playerid), string[128], Float:posX, Float:posY, Float:posZ;

		if(giveplayerid == INVALID_PLAYER_ID) return true;
		if(GetPVarInt(playerid, "TazerAvailable") == 0) return SendClientMessage(playerid, COLOR_RED, "* Der Tazer ist noch nicht wieder aufgeladen."); // change

		//if((pStats[giveplayerid][pFaction] == 1) return SendClientMessage(playerid, COLOR_RED, "* Du kannst keine anderen Polizisten tazern.");
		if(IsPlayerInAnyVehicle(giveplayerid)) return SendClientMessage(playerid, COLOR_RED, "* Du kannst niemanden Tazern, der in einem Vehikel sitzt.");
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "* Du kannst aus einem Vehikel heraus niemanden Tazern.");

		GetPlayerPos(giveplayerid, posX, posY, posZ);
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, posX, posY, posZ)) {
			SetPVarInt(playerid, "TazerAvailable", 0);
			SetTimerEx("_resetTazerAvailability", 30000, false, "i", playerid); // 30sek

	        format(string, sizeof(string), "* Der Tazerschuss erreichte %s nicht.", _getName(giveplayerid));
			SendClientMessage(playerid, COLOR_RED, string);
			
			format(string, sizeof(string), "* %s hat einen Tazerschuss auf %s aufgrund von der Entfernung verfehlt.", _getName(playerid), _getName(giveplayerid));
			_sendNearByMessage(playerid, COLOR_LIGHTBLUE, string);
			return true;
		}
		
		if(newkeys & KEY_SPRINT && random(1) == 0) {
			SetPVarInt(playerid, "TazerAvailable", 0);
			SetTimerEx("_resetTazerAvailability", 45000, false, "i", playerid); // 45sec

			format(string, sizeof(string), "* %s hat einen Tazerschuss auf %s verfehlt.", _getName(playerid), _getName(giveplayerid));
			_sendNearByMessage(playerid, COLOR_LIGHTBLUE, string);
			return true;
		}

		ApplyAnimation(giveplayerid, "CRACK", "crckdeth2", 3.5, 1, 0, 0, 10000, 0); // 10sec
		SetTimerEx("_unfreezePlayer", 10000, false, "i", giveplayerid);

		SetPVarInt(playerid, "TazerAvailable", 0);
		SetTimerEx("_resetTazerAvailability", 120000, false, "i", playerid); // 2min

		format(string, sizeof(string), "* %s hat %s mit einem Tazerschuss getroffen.", _getName(playerid), _getName(giveplayerid));
		_sendNearByMessage(playerid, COLOR_LIGHTBLUE, string);
	}
    return true;
}


public OnRconLoginAttempt(ip[], password[], success) return true;
public OnPlayerUpdate(playerid) return true;
public OnPlayerStreamIn(playerid, forplayerid) return true;
public OnPlayerStreamOut(playerid, forplayerid) return true;
public OnVehicleStreamIn(vehicleid, forplayerid) return true;
public OnVehicleStreamOut(vehicleid, forplayerid) return true;


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new string[2048];
    new giveplayerid = GetPVarInt(playerid,"ClickedPlayer");

    switch(dialogid) {
        case PLAYER_DIALOG_LOGIN:   // login
        {
            if(!response) Kick(playerid);
            if(strlen(inputtext) < 4 || strlen(inputtext) > 30) {
				ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein gewähltes Passwort ein.", "Login", "Abbrechen");
				return false;
			}

			new sha256str[H_SHA256_LEN]; hhash(H_SHA256, inputtext, sha256str, sizeof(sha256str));

            if(strcmp(sha256str, pStats[playerid][pPassword], false) == 0) {
                if(strlen(sConfig[motd]) != 0) {
                    format(string, sizeof(string), "\r\n%s\r\n", sConfig[motd]);
                    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "MOTD", string, "OK", " ");
                }
                SetPVarInt(playerid, "Authentication", 1);
                SetPVarInt(playerid, "JustLogged", 1);
                pStats[playerid][pLogins] ++;
            }
            else ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein gewähltes Passwort ein.", "Login", "Abbrechen");
			return true;
		}
		
		/*case 1: { // registration
		    if(!response) Kick(playerid);
		    else if(strlen(inputtext) < 4 || strlen(inputtext) > 30) ShowPlayerDialog(playerid, PLAYER_DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registration", "Bitte tippe dein gewünschtes Passwort ein.\n[4-30 Zeichen]", "Registration", "Abbrechen");
		    format(querystring, sizeof(querystring), "INSERT INTO `accounts` (username, password) VALUES('%s', '%s')", _getEscName(playerid), inputtext); mysql_query(query); // evtl. noch andere Werte wie IP usw. setzen
		    SpawnPlayer(playerid);
		}*/
		
        case PLAYER_DIALOG_CLICKEDADM:                             // ClickedPlayer(admin)
        {
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
            return true;
        }
        
        case PLAYER_DIALOG_CLICKED:   //ClickedPlayer(Player)
        {
            if(!response) return false;
            switch(listitem) {
                case 0:                           // Call
                {
                }
                case 1:                           // SMS
                {
                }
            }
            return true;
        }
        
        case PLAYER_DIALOG_CLICKEDADM_MENU:   // adminmenu (kick, ban, ...)
        {
            if(!response) return false;
            //if(GetPVarInt(playerid, "AdminDuty") == 0) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_NOTONDUTY);
            switch(listitem) {
				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_ACCOUNT:
				{
	    			if(pStats[playerid][pAdminLevel] < 3)                       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
				    new coordstring[6][256];
				    
					format(coordstring[0], sizeof(coordstring[]), "----------*** %s (%s) ***----------", _getName(giveplayerid), pStats[giveplayerid][pEmail]);
					format(coordstring[1], sizeof(coordstring[]), "* IP: %s | Logins: %d | AdminLevel: %d | Fraktion: %d (Rang: %d) | Duty: %d | Job: %d", pStats[giveplayerid][pIPAddress], pStats[giveplayerid][pLogins], pStats[giveplayerid][pAdminLevel], pStats[giveplayerid][pFaction], pStats[giveplayerid][pFactionRank], pStats[giveplayerid][pDuty], pStats[giveplayerid][pJob]);
					format(coordstring[2], sizeof(coordstring[]), "* Cash: %d | bank: %d | Level: %d | Skin: %d | Health: %f | Armor: %d", pStats[giveplayerid][pCash], pStats[giveplayerid][pBank], pStats[giveplayerid][pLevel], pStats[giveplayerid][pSkin],pStats[giveplayerid][pHealth], pStats[giveplayerid][pArmor]);
					format(coordstring[3], sizeof(coordstring[]), "* Warns: %d | Warning1: %s | Warning2: %s | Warning3: %s | BannedUntil: %d", pStats[giveplayerid][pWarns], pStats[giveplayerid][pWarning1], pStats[giveplayerid][pWarning2], pStats[giveplayerid][pWarning3], pStats[giveplayerid][pBanstamp]);
					format(coordstring[4], sizeof(coordstring[]), "* LicenseCar: %d | LicenseBike: %d | LicenseAir: %d | VehicleID1: %d | VehicleID2: %d | VehicleID3: %d", pStats[playerid][pLicenseCar], pStats[playerid][pLicenseBike], pStats[playerid][pLicenseAir], pStats[giveplayerid][pVeh1], pStats[giveplayerid][pVeh2], pStats[giveplayerid][pVeh3]);
					format(coordstring[5], sizeof(coordstring[]), "* PosX: %f | PosY: %f | PosZ: %f | PosA: %f", pStats[giveplayerid][pPosX], pStats[giveplayerid][pPosY], pStats[giveplayerid][pPosZ], pStats[giveplayerid][pPosA]);
					format(string, sizeof(string), "%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n", coordstring[0], coordstring[1], coordstring[2], coordstring[3], coordstring[4], coordstring[5]);
					ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "Account", string, "OK", " ");
	    			return true;
				}

				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICK:                           // kick
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICKRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Kick", "Abbrechen");
					return true;
				}

				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_BAN:                           // ban
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_BANRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Ban", "Abbrechen");
                    return true;
                }

				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_GOTO:                           // goto
                {
                    if(pStats[playerid][pAdminLevel] < 2) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
                    new vehicle, Float:X, Float:Y, Float:Z;
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
                    format(string, sizeof(string), "** Du hast dich zu %s teleportiert.", _getName(giveplayerid));
                    SendClientMessage(playerid, COLOR_PURPLE, string);
                    format(string, sizeof(string), "** Administrator %s hat sich zu dir teleportiert.", _getName(playerid));
                    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

					format(string, sizeof(string), "** Administrator %s hat sich zu %s teleportiert.", _getName(playerid), _getName(giveplayerid));
    				_logToFile("admin", string);
					return true;
				}

				case PLAYER_DIALOG_CLICKEDADM_ADMMENU_GETHERE:                           // gethere
                {
                    new vehicle, Float:X, Float:Y, Float:Z;
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
                    format(string, sizeof(string), "** Du wurdest zu Administrator %s teleportiert.", _getName(playerid));
                    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

                    format(string, sizeof(string), "** Du hast %s zu dir teleportiert.", _getName(giveplayerid));
                    SendClientMessage(playerid, COLOR_PURPLE, string);
                    
					format(string, sizeof(string), "** Administrator %s hat %s zu sich teleportiert.", _getName(playerid), _getName(giveplayerid));
    				_logToFile("admin", string);
					return true;
				}

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_FREEZE:                           // freeze
                {
                    if(pStats[playerid][pAdminLevel] < 2)                       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

					switch(GetPVarInt(giveplayerid, "PlayerFrozen")) {
						case 0: {
	                        TogglePlayerControllable(giveplayerid, false);
	                        SetPVarInt(giveplayerid, "PlayerFrozen", 1);

	                        format(string, sizeof(string), "** Administrator %s hat dich eingefroren.", _getName(playerid));
	                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Du hast %s eingefroren", _getName(giveplayerid));
	                        SendClientMessage(playerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Administrator %s hat %s eingefroren.", _getName(playerid), _getName(giveplayerid));
	                        SendClientMessageToAll(COLOR_PURPLE, string);
	    					_logToFile("admin", string);
	                    }
                        case 1: {
	                        TogglePlayerControllable(giveplayerid, true);
	                        SetPVarInt(giveplayerid, "PlayerFrozen", 0);

	                        format(string, sizeof(string), "** Administrator %s hat dich aufgetaut.", _getName(playerid));
	                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Du hast %s aufgetaut", _getName(giveplayerid));
	                        SendClientMessage(playerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Administrator %s hat %s aufgetaut.", _getName(playerid), _getName(giveplayerid));
	                        SendClientMessageToAll(COLOR_PURPLE, string);
	                        _logToFile("admin", string);
						}
                    }
					return true;
				}

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARN:                           // warn
                {
                    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARNRSN, DIALOG_STYLE_INPUT, "Grund", " ", "Verwarnen", "Abbrechen");
					return true;
                }

                case PLAYER_DIALOG_CLICKEDADM_ADMMENU_MUTE:                           // mute
                {
					switch(GetPVarInt(giveplayerid, "PlayerMuted")) {
						case 0: {
	                        SetPVarInt(giveplayerid, "PlayerMuted", 1);

	                        format(string, sizeof(string), "** Administrator %s hat dich stumm gestellt.", _getName(playerid));
	                        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Du hast %s stumm gestellt.", _getName(giveplayerid));
	                        SendClientMessage(playerid, COLOR_PURPLE, string);

	                        format(string, sizeof(string), "** Administrator %s hat %s stumm gestellt.", _getName(playerid), _getName(giveplayerid));
	                        SendClientMessageToAll(COLOR_PURPLE, string);
	                        _logToFile("admin", string);
						}

						case 1: {
		                    SetPVarInt(playerid, "PlayerMuted", 0);

		                    format(string, sizeof(string), "** Administrator %s hat dich entstummt.", _getName(playerid));
		                    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		                    format(string, sizeof(string), "** Du hast %s entstummt.", _getName(giveplayerid));
		                    SendClientMessage(playerid, COLOR_PURPLE, string);

		                    format(string, sizeof(string), "** Administrator %s hat %s entstummt.", _getName(playerid), _getName(giveplayerid));
		                    SendClientMessageToAll(COLOR_PURPLE, string);
		                    _logToFile("admin", string);
						}
					}
					return true;
				}
    		}
        }
        
		case PLAYER_DIALOG_CLICKEDADM_ADMMENU_KICKRSN:   // kick reason
        {
            if(!response) return false;
            if(strlen(inputtext) == 0) {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gekickt.", _getName(playerid));
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gekickt.", _getName(playerid), _getName(giveplayerid));
                SendClientMessageToAll(COLOR_PURPLE, string);
            }
            else {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gekickt. Grund: %s", _getName(playerid), inputtext);
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gekickt. Grund: %s", _getName(playerid), _getName(giveplayerid), inputtext);
                SendClientMessageToAll(COLOR_PURPLE, string);
                _logToFile("admin", string);
            }
            Kick(giveplayerid);
            return true;
        }
        
        case PLAYER_DIALOG_CLICKEDADM_ADMMENU_BANRSN:   // ban reason
        {
            if(!response) return false;
            if(strlen(inputtext) == 0) {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gebannt.", _getName(playerid));
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gebannt.", _getName(playerid), _getName(giveplayerid));
                SendClientMessageToAll(COLOR_PURPLE, string);
            }
            else {
                format(string, sizeof(string), "** Du wurdest von Administrator %s gebannt. Grund: %s", _getName(playerid), inputtext);
                SendClientMessage(giveplayerid, COLOR_RED, string);

                format(string, sizeof(string), "** Administrator %s hat %s gebannt. Grund: %s", _getName(playerid), _getName(giveplayerid), inputtext);
                SendClientMessageToAll(COLOR_PURPLE, string);
                _logToFile("admin", string);
            }
            Ban(giveplayerid);
            return true;
        }
        
        case PLAYER_DIALOG_CLICKEDADM_ADMMENU_WARNRSN:  // warn reason
        {
            if(!response) return false;
            if(GetPVarInt(giveplayerid, "Authentication") != 1)         return SendClientMessage(playerid, COLOR_RED,  ERRORMESSAGE_USER_ID_NOTONLINE);
            pStats[giveplayerid][pWarns] ++;
			if(strlen(inputtext) == 0) {
                /*format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt [%d/3].", _getName(playerid), _getName(giveplayerid), giveplayerid, pStats[giveplayerid][pWarns]);
                SendClientMessageToAll(COLOR_PURPLE, string);
                _logToFile("admin", string);*/
                return false;
            }
            else {
		        format(string, sizeof(string), "** Administrator %s hat %s [ID: %d] verwarnt [%d/3]. Grund: %s", _getName(playerid), _getName(giveplayerid), giveplayerid, pStats[giveplayerid][pWarns], inputtext);
		        SendClientMessageToAll(COLOR_PURPLE, string);
		        _logToFile("admin", string);
            }

			switch(pStats[giveplayerid][pWarns]) {
			    case 1: {
	                SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 1/3 gestiegen.");
	                format(querystring, sizeof(querystring), "UPDATE `accounts` SET `warning1` = '%s' WHERE `username` = '%s'", inputtext, _getName(giveplayerid));
					mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");
				    strdel(pStats[playerid][pWarning1], 0, 256), strcat(pStats[playerid][pWarning1], inputtext, 256);
				}

				case 2: {
	                SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 2/3 gestiegen.");
	                format(querystring, sizeof(querystring), "UPDATE `accounts` SET `warning2` = '%s' WHERE `username` = '%s'", inputtext, _getName(giveplayerid));
					mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");
				    strdel(pStats[playerid][pWarning2], 0, 256), strcat(pStats[playerid][pWarning2], inputtext, 256);
				}

				case 3: {
	                SendClientMessage(giveplayerid, COLOR_RED, "** Deine Verwarnungen sind auf 3/3 gestiegen.");
	                format(string, sizeof(string), "** %s [ID: %d] wurde aufgrund von zuvielen Verwarnungen vom Server gebannt.", _getName(giveplayerid), giveplayerid);
	                SendClientMessageToAll(COLOR_PURPLE, string);

	                new banduration = (gettime() + 604800); // 1 week

	                format(querystring, sizeof(querystring), "UPDATE `accounts` SET `warning3` = '%s', `banstamp` = %d WHERE `username` = '%s'", inputtext, banduration, _getName(giveplayerid));
					mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");
				    strdel(pStats[playerid][pWarning3], 0, 256), strcat(pStats[playerid][pWarning3], inputtext, 256);

					Kick(giveplayerid);
				}
			}
			_OnMySQLPlayerDataSave(giveplayerid);
			return true;
        }
    }
    return false;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    SetPVarInt(playerid,"ClickedPlayer", clickedplayerid);
    if(pStats[playerid][pAdminLevel] >= 1) return ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKEDADM, DIALOG_STYLE_LIST, "Menü", "Admin-Menü\nAnrufen\nSMS\n", "Auswählen", "Abbrechen");
    ShowPlayerDialog(playerid, PLAYER_DIALOG_CLICKED, DIALOG_STYLE_LIST, "Menü", "Anrufen\nSMS\n", "Auswählen", "Abbrechen");
    return true;
}


public OnQueryError(errorid, error[], callback[], query[], connectionHandle) {
	new string[256];
	format(string, sizeof(string), "\r\nMYSQL Error (ID: %d): %s\r\n- on callback: %s\r\n- On query: %s", errorid, error, callback, query);
	printf(string);
	//_logToFile(string, "mysql_error");
	return true;
}


//------------------------------------------------------------------------------ CUSTOM CALLBACKS


public _OnMySQLConfigurationLoad()
{
    new rows, fields;
    cache_get_data(rows, fields);

    new temp[128];
    //cache_get_field_content(0, "config_id", 		temp), sConfig[configID] = strval(temp);
    cache_get_field_content(0, "motd", 	   			temp), strcat(sConfig[motd], temp, sizeof(sConfig[motd]));
    cache_get_field_content(0, "taxes", 			temp), sConfig[taxes] = strval(temp);
    cache_get_field_content(0, "faction_1_funds", 	temp), sConfig[faction_1_funds] = strval(temp);
    cache_get_field_content(0, "faction_2_funds", 	temp), sConfig[faction_2_funds] = strval(temp);
    cache_get_field_content(0, "faction_3_funds", 	temp), sConfig[faction_3_funds] = strval(temp);
    cache_get_field_content(0, "faction_4_funds", 	temp), sConfig[faction_4_funds] = strval(temp);
    cache_get_field_content(0, "faction_5_funds", 	temp), sConfig[faction_5_funds] = strval(temp);

	printf("Database information:\r\n- MOTD: %s\r\n- TAXES: %d", sConfig[motd], sConfig[taxes]);
	return true;
}


public _OnMySQLPlayerDataSave(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;

    if(GetPVarInt(playerid, "LoggingOut") == 0) GetPlayerIp(playerid, pStats[playerid][pIPAddress], 17);
    pStats[playerid][pCash]         = GetPlayerCash(playerid);

    if(pStats[playerid][pDuty] == 0) {
	    pStats[playerid][pSkin]         = GetPlayerSkin(playerid);
	    GetPlayerHealth(playerid,       pStats[playerid][pHealth]);
	    GetPlayerArmour(playerid,       pStats[playerid][pArmor]);
    }
    
    GetPlayerPos(playerid,          pStats[playerid][pPosX], pStats[playerid][pPosY], pStats[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid,  pStats[playerid][pPosA]);

	new bigstring[2048];
    format(bigstring, sizeof(bigstring), "UPDATE `accounts` SET `ip` = '%s', `adminLevel` = '%d', `faction` = '%d', `factionRank` = '%d', `duty` = '%d', `wantedLevel` = '%d', \
											 `job` = '%d', `cash` = '%d', `bank` = '%d', `level` = '%d', `skin` = '%d', `health` = '%f', `armor` = '%f', `posX` = '%f', `posY` = '%f', \
											 `posZ` = '%f', `posA` = '%f' WHERE `username` = '%s'",
    	/*
		`password` = '%s', `email` = '%s',
		pStats[playerid][pPassword],
    	pStats[playerid][pEmail],*/
		pStats[playerid][pIPAddress],
		pStats[playerid][pAdminLevel],
		pStats[playerid][pFaction],
		pStats[playerid][pFactionRank],
		pStats[playerid][pDuty],
		pStats[playerid][pWantedLevel],
		pStats[playerid][pJob],
		pStats[playerid][pCash],
		pStats[playerid][pBank],
		pStats[playerid][pLevel],
		pStats[playerid][pSkin],
		pStats[playerid][pHealth],
		pStats[playerid][pArmor],
		pStats[playerid][pPosX],
		pStats[playerid][pPosY],
		pStats[playerid][pPosZ],
		pStats[playerid][pPosA],
		_getEscName(playerid));
	mysql_function_query(MYSQL_DBHANDLE, bigstring, false, "", "");

    format(bigstring, sizeof(bigstring), "UPDATE `accounts` SET `logins` = '%d', `warns` = '%d', `banstamp` = '%d', `vehicleID1` = '%d', `vehicleID2` = '%d', \
										 `vehicleID3` = '%d', `licenseCar` = '%d', `licenseBike` = '%d', \
					         			 `licenseAir` = '%d' WHERE `username` = '%s'",
		pStats[playerid][pLogins],
		pStats[playerid][pWarns],
		pStats[playerid][pBanstamp],
		pStats[playerid][pVeh1],
		pStats[playerid][pVeh2],
		pStats[playerid][pVeh3],
 		pStats[playerid][pLicenseCar],
		pStats[playerid][pLicenseBike],
		pStats[playerid][pLicenseAir],
		_getEscName(playerid)
	);
	mysql_function_query(MYSQL_DBHANDLE, bigstring, false, "", "");
    return true;
}


public _OnMySQLPlayerDataLoad(playerid)
{
    new temp[512], rows, fields;

    cache_get_data(rows, fields);
    if(!rows) return false;

    cache_get_field_content(0, "username", 			temp), strdel(pStats[playerid][pUsername], 	0, 25),		strcat(pStats[playerid][pUsername], 	temp, 25);
    cache_get_field_content(0, "password", 			temp), strdel(pStats[playerid][pPassword], 	0, 65),		strcat(pStats[playerid][pPassword], 	temp, 65);
    cache_get_field_content(0, "email", 			temp), strdel(pStats[playerid][pEmail], 	0, 129), 	strcat(pStats[playerid][pEmail],		temp, 129);
    cache_get_field_content(0, "ip", 				temp), strdel(pStats[playerid][pIPAddress], 0, 17), 	strcat(pStats[playerid][pIPAddress], 	temp, 17);

    cache_get_field_content(0, "justRegistered",	temp), pStats[playerid][pJustRegistered]	= strval(temp);
    cache_get_field_content(0, "adminLevel", 		temp), pStats[playerid][pAdminLevel]		= strval(temp);
    cache_get_field_content(0, "faction", 			temp), pStats[playerid][pFaction] 			= strval(temp);
    cache_get_field_content(0, "factionRank", 		temp), pStats[playerid][pFactionRank] 		= strval(temp);
    cache_get_field_content(0, "duty", 				temp), pStats[playerid][pDuty] 				= strval(temp);
    cache_get_field_content(0, "wantedLevel", 		temp), pStats[playerid][pWantedLevel] 		= strval(temp);
    cache_get_field_content(0, "job", 				temp), pStats[playerid][pJob] 				= strval(temp);
    cache_get_field_content(0, "cash", 				temp), pStats[playerid][pCash] 				= strval(temp);
    cache_get_field_content(0, "bank", 				temp), pStats[playerid][pBank] 				= strval(temp);
    cache_get_field_content(0, "level", 			temp), pStats[playerid][pLevel] 			= strval(temp);
    cache_get_field_content(0, "skin", 				temp), pStats[playerid][pSkin] 				= strval(temp);

    cache_get_field_content(0, "health", 			temp), pStats[playerid][pHealth] 			= floatstr(temp);
    cache_get_field_content(0, "armor", 			temp), pStats[playerid][pArmor] 			= floatstr(temp);
    cache_get_field_content(0, "posX",		 		temp), pStats[playerid][pPosX] 				= floatstr(temp);
    cache_get_field_content(0, "posY", 				temp), pStats[playerid][pPosY] 				= floatstr(temp);
    cache_get_field_content(0, "posZ", 				temp), pStats[playerid][pPosZ] 				= floatstr(temp);
    cache_get_field_content(0, "posA", 				temp), pStats[playerid][pPosA] 				= floatstr(temp);

    cache_get_field_content(0, "logins", 			temp), pStats[playerid][pLogins] 			= strval(temp);
    cache_get_field_content(0, "warns", 			temp), pStats[playerid][pWarns] 			= strval(temp);

    cache_get_field_content(0, "warning1", 			temp), strdel(pStats[playerid][pWarning1], 0, 129), strcat(pStats[playerid][pWarning1], temp, 129);
    cache_get_field_content(0, "warning2", 			temp), strdel(pStats[playerid][pWarning2], 0, 129), strcat(pStats[playerid][pWarning2], temp, 129);
    cache_get_field_content(0, "warning3", 			temp), strdel(pStats[playerid][pWarning3], 0, 129), strcat(pStats[playerid][pWarning3], temp, 129);
    
    cache_get_field_content(0, "banstamp", 			temp), pStats[playerid][pBanstamp] 		= strval(temp);

    cache_get_field_content(0, "vehicleID1", 		temp), pStats[playerid][pVeh1] 			= strval(temp);
    cache_get_field_content(0, "vehicleID2", 		temp), pStats[playerid][pVeh2] 			= strval(temp);
    cache_get_field_content(0, "vehicleID3", 		temp), pStats[playerid][pVeh3] 			= strval(temp);

    cache_get_field_content(0, "licenseCar", 		temp), pStats[playerid][pLicenseCar] 	= strval(temp);
    cache_get_field_content(0, "licenseBike", 		temp), pStats[playerid][pLicenseBike] 	= strval(temp);
    cache_get_field_content(0, "licenseAir", 		temp), pStats[playerid][pLicenseAir]	= strval(temp);

	if(pStats[playerid][pFaction] == 0) pStats[playerid][pFactionRank] = 0;
	if(pStats[playerid][pFaction] > 0 && pStats[playerid][pFactionRank] == 0) pStats[playerid][pFactionRank] = 1;
	
	if(GetPVarInt(playerid, "Authentication") != 1) {
		/*if(gettime() < pStats[playerid][pBanstamp]) {    // buggy cause of datatypes (int <> double)
			new banned[15];
		    format(string, sizeof(string), "** Du bist noch %s gebannt.", timec(gettime(), strval(banned)));
			SendClientMessage(playerid, COLOR_RED, string);
		}*/

	    if(strcmp(pStats[playerid][pUsername], _getEscName(playerid)) == 0) ShowPlayerDialog(playerid, PLAYER_DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", "Bitte tippe dein gewähltes Passwort ein.", "Login", "Abbrechen");
	    else {
	        ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "Account", "Dieser Account ist noch nicht registriert.\r\nBitte hole dies auf www.suchtstation.de nach.", "OK", " ");
	        //Kick(playerid);
	        return true;
	    }
	}
    return true;
}


YCMD:savecar(playerid, params[], help)
{
    _OnMySQLVehicleDataSave(GetPlayerVehicleID(playerid));
	return true;
}


YCMD:loadcar(playerid, params[], help)
{
    _OnMySQLVehicleDataLoad();
	return true;
}


public _OnMySQLVehicleDataSave(vehicleid)
{
	new dmg[9];
	
	vVehicles[vehicleid][vVehicleID] = vehicleid;
	GetVehiclePos(vehicleid, 			vVehicles[vehicleid][vPosX], vVehicles[vehicleid][vPosY], vVehicles[vehicleid][vPosZ]);
	GetVehicleZAngle(vehicleid, 		vVehicles[vehicleid][vPosA]);
	GetVehicleHealth(vehicleid, 		vVehicles[vehicleid][vHealth]);

	_getVehiclePanelDamageStatus(vVehicles[vehicleid][vVehicleID], dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5], dmg[6]), 	format(vVehicles[vehicleid][vPanelDamage], 	14, "%d|%d|%d|%d|%d|%d|%d", dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5], dmg[6]);
	_getVehicleDoorDamageStatus(vVehicles[vehicleid][vVehicleID], dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5]), 			format(vVehicles[vehicleid][vDoorDamage], 	12, "%d|%d|%d|%d|%d|%d", dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5]);
	_getVehicleLightDamageStatus(vVehicles[vehicleid][vVehicleID], dmg[0], dmg[1], dmg[2], dmg[3]), 							format(vVehicles[vehicleid][vLightDamage], 	8, "%d|%d|%d|%d", dmg[0], dmg[1], dmg[2], dmg[3]);
	_getVehicleTireDamageStatus(vVehicles[vehicleid][vVehicleID], dmg[0], dmg[1], dmg[2], dmg[3]), 							format(vVehicles[vehicleid][vTireDamage], 	8, "%d|%d|%d|%d", dmg[0], dmg[1], dmg[2], dmg[3]);

	new bigstring[2048];
    format(bigstring, sizeof(bigstring), "UPDATE `vehicles` SET `vehicleid` = '%d', `owner` = '%s', `model` = '%d', `health` = '%f', `panelDamage` = '%s', `doorDamage` = '%s', \
											`lightDamage` = '%s', `tireDamage` = '%s', `posX` = '%f', `posY` = '%f', `posZ` = '%f', `posA` = '%f', `color1` = '%d', `color2` = '%d', \
											`navigation` = '%d', `locked` = '%d', `fuel` = '%d', `filled` = '%d' WHERE `plate` = '%s'",
		vVehicles[vehicleid][vVehicleID],
		vVehicles[vehicleid][vOwner],
		vVehicles[vehicleid][vModelID],
		vVehicles[vehicleid][vHealth],
 		vVehicles[vehicleid][vPanelDamage],
	    vVehicles[vehicleid][vDoorDamage],
		vVehicles[vehicleid][vLightDamage],
	 	vVehicles[vehicleid][vTireDamage],
		vVehicles[vehicleid][vPosX],
		vVehicles[vehicleid][vPosY],
		vVehicles[vehicleid][vPosZ],
		vVehicles[vehicleid][vPosA],
		vVehicles[vehicleid][vColor1],
		vVehicles[vehicleid][vColor2],
	 	vVehicles[vehicleid][vNavigation],
	 	vVehicles[vehicleid][vLocked],
		vVehicles[vehicleid][vFuel],
		vVehicles[vehicleid][vFilled],
		
		vVehicles[vehicleid][vPlate]
	);
	mysql_function_query(MYSQL_DBHANDLE, bigstring, false, "", "");
	
	printf("\r\nPlate: %s, vehID: %d, Owner: %s, Model: %d, Health: %f,\r\n panelDamage: %s, doorDamage: %s, lightDamage: %s, tireDamage: %s,\r\n posX: %f, posY: %f, posZ: %f, posA: %f,\r\n Color1: %d, Color2: %d, Navigation: %d, Locked: %d, Fuel: %d, Filled: %d\r\n",
	vVehicles[vehicleid][vPlate], vVehicles[vehicleid][vVehicleID], vVehicles[vehicleid][vOwner], vVehicles[vehicleid][vModelID], vVehicles[vehicleid][vHealth], vVehicles[vehicleid][vPanelDamage], vVehicles[vehicleid][vDoorDamage], vVehicles[vehicleid][vLightDamage], vVehicles[vehicleid][vTireDamage],
	vVehicles[vehicleid][vPosX], vVehicles[vehicleid][vPosY], vVehicles[vehicleid][vPosZ], vVehicles[vehicleid][vPosA],
	vVehicles[vehicleid][vColor1], vVehicles[vehicleid][vColor2], vVehicles[vehicleid][vNavigation], vVehicles[vehicleid][vLocked], vVehicles[vehicleid][vFuel], vVehicles[vehicleid][vFilled]);
	return true;
}


public _OnMySQLVehicleDataLoad()
{
    new rows, fields, temp[128], k = 1, dmg[9];
    cache_get_data(rows, fields);

    for(new i = 0; i < rows -1; i++) {
	    cache_get_field_content(k, "plate", 			temp), strcat(vVehicles[k][vPlate], temp, 9);
    	cache_get_field_content(k, "vehicleid", 		temp), vVehicles[k][vVehicleID] 	= strval(temp);
	    cache_get_field_content(k, "owner", 			temp), strcat(vVehicles[k][vOwner], temp, 25);
    	cache_get_field_content(k, "model", 			temp), vVehicles[k][vModelID] 		= strval(temp);
    	cache_get_field_content(k, "health", 			temp), vVehicles[k][vHealth] 		= floatstr(temp);
    	cache_get_field_content(k, "panelDamage", 		temp), strcat(vVehicles[k][vPanelDamage], 	temp, 14);
    	cache_get_field_content(k, "doorDamage", 		temp), strcat(vVehicles[k][vDoorDamage], 	temp, 12);
    	cache_get_field_content(k, "lightDamage", 		temp), strcat(vVehicles[k][vLightDamage], 	temp, 8);
    	cache_get_field_content(k, "tireDamage", 		temp), strcat(vVehicles[k][vTireDamage], 	temp, 8);
    	cache_get_field_content(k, "posX", 				temp), vVehicles[k][vPosX] 			= floatstr(temp);
    	cache_get_field_content(k, "posY", 				temp), vVehicles[k][vPosY] 			= floatstr(temp);
    	cache_get_field_content(k, "posZ", 				temp), vVehicles[k][vPosZ] 			= floatstr(temp);
    	cache_get_field_content(k, "posA", 				temp), vVehicles[k][vPosA] 			= floatstr(temp);
    	cache_get_field_content(k, "color1", 			temp), vVehicles[k][vColor1] 		= strval(temp);
    	cache_get_field_content(k, "color2", 			temp), vVehicles[k][vColor2] 		= strval(temp);
    	cache_get_field_content(k, "navigation", 		temp), vVehicles[k][vNavigation] 	= strval(temp);
    	cache_get_field_content(k, "locked", 			temp), vVehicles[k][vLocked] 		= strval(temp);
    	cache_get_field_content(k, "fuel", 				temp), vVehicles[k][vFuel] 			= strval(temp);
    	cache_get_field_content(k, "filled", 			temp), vVehicles[k][vFilled] 		= strval(temp);

		vVehicles[k][vVehicleID] = CreateVehicle(vVehicles[k][vModelID], vVehicles[k][vPosX], vVehicles[k][vPosY], vVehicles[k][vPosZ], vVehicles[k][vPosA], vVehicles[k][vColor1], vVehicles[k][vColor2], 0),
		SetVehicleHealth(vVehicles[k][vVehicleID], vVehicles[k][vHealth]);
		SetVehicleNumberPlate(vVehicles[k][vVehicleID], vVehicles[k][vPlate]);

		sscanf(vVehicles[k][vPanelDamage], 	"p<|>iiiiiii", 	dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5], dmg[6]), 	_updateVehiclePanelDamageStatus(vVehicles[k][vVehicleID],	dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5], dmg[6]);
		sscanf(vVehicles[k][vDoorDamage], 	"p<|>iiiiii", 	dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5]), 			_updateVehicleDoorDamageStatus(vVehicles[k][vVehicleID], 	dmg[0], dmg[1], dmg[2], dmg[3], dmg[4], dmg[5]);
		sscanf(vVehicles[k][vLightDamage], 	"p<|>iiii", 	dmg[0], dmg[1], dmg[2], dmg[3]), 							_updateVehicleLightDamageStatus(vVehicles[k][vVehicleID], 	dmg[0], dmg[1], dmg[2], dmg[3]);
		sscanf(vVehicles[k][vTireDamage], 	"p<|>iiii", 	dmg[0], dmg[1], dmg[2], dmg[3]), 							_updateVehicleTireDamageStatus(vVehicles[k][vVehicleID], 	dmg[0], dmg[1], dmg[2], dmg[3]);

		printf("\r\nPlate: %s, vehID: %d, Owner: %s, Model: %d, Health: %f,\r\n panelDamage: %s, doorDamage: %s, lightDamage: %s, tireDamage: %s,\r\n posX: %f, posY: %f, posZ: %f, posA: %f,\r\n Color1: %d, Color2: %d, Navigation: %d, Locked: %d, Fuel: %d, Filled: %d\r\n",
		vVehicles[k][vPlate], vVehicles[k][vVehicleID], vVehicles[k][vOwner], vVehicles[k][vModelID], vVehicles[k][vHealth], vVehicles[k][vPanelDamage], vVehicles[k][vDoorDamage], vVehicles[k][vLightDamage], vVehicles[k][vTireDamage],
		vVehicles[k][vPosX], vVehicles[k][vPosY], vVehicles[k][vPosZ], vVehicles[k][vPosA],
		vVehicles[k][vColor1], vVehicles[k][vColor2], vVehicles[k][vNavigation], vVehicles[k][vLocked], vVehicles[k][vFuel], vVehicles[k][vFilled]);

       //ChangeVehicleBlowjob(veh[k] xx);
		k++;
	}
	vTotal = (k - 1);
	//_MySQLVehicleCount(vTotal);
	return true;
}

stock _MySQLGetVehicleCount() {
	new rows, fields, i;
	cache_get_data(rows, fields);
	printf("rows: %d", i);
	return i;
}

/*
//    mysql_query("SELECT COUNT(*) FROM `vehicles`"); mysql_store_result();
//	new count = mysql_fetch_int(); mysql_free_result();


*/
/*	new idx = 0;
	new Float:X, Float:Y, Float:Z, Float:A;
	new owner[128], model, color1, color2;

	for(new i = 0; i < count; i++) {
		format(querystring, sizeof(querystring), "SELECT `owner` FROM `vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 		if(mysql_fetch_row(owner) == 1) mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `model` FROM `vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  	model = mysql_fetch_int(); mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `posX` FROM `vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(X) == 1) mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `posY` FROM `vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(Y) == 1) mysql_free_result();
 		format(querystring, sizeof(querystring), "SELECT `posZ` FROM `vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(Z) == 1) mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `posA` FROM `vehicles` WHERE `vehicleID` = '%d'", i); mysql_query(query); mysql_store_result(); 	if(mysql_fetch_float(A) == 1) mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `color1` FROM `vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  color1 = mysql_fetch_int(); mysql_free_result();
		format(querystring, sizeof(querystring), "SELECT `color2` FROM `vehicles` WHERE 	`vehicleID` = '%d'", i); mysql_query(query); mysql_store_result();  color2 = mysql_fetch_int(); mysql_free_result();

    	AddStaticVehicle(model, X, Y, Z, A, color1, color2);
		//Vehicles[vehicleid][pVeh1]  = mysql_GetVehicleFloat("posX", "vehicleID", i);
		idx++;

		printf("Owner: %s, Model: %d, X: %f, Y: %f, Z: %f, A: %f, Color1: %d, Color2: %d", owner, model, X, Y, Z, A, color1, color2);
	}

*/
    //format(querystring, sizeof(querystring), "SELECT `%s` FROM `%s` WHERE `%s` = '%s'", field, table, req, requirement); mysql_query(query); mysql_store_result();
	/*
    new index;
    mysql_query("SELECT * FROM `vehicles`");
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

	format(querystring, sizeof(querystring), "INSERT INTO `vehicles` (model, posX, posY, posZ, angle, color1, color2) VALUES(%d, %f, %f, %f, %f, %d, %d)", ModelID, PositionX, PositionY, PositionZ, AngleZ, Color1, Color2);
	mysql_query(query);

*/

/*	foreach(Player, i)

	for(new i = 0; i < MAX_VEHICLES; i++) {
		Vehicles[
	    mysql_query("SELECT posX FROM `vehicles` WHERE `owner` = "%s", );
	}



*/
//	printf("\n* SERVER: Loaded %d MySQL vehicles successfully.", idx);


public _OnPlayerDataAssign(playerid)
{
    if(GetPVarInt(playerid, "Authentication") != 1) return false;

    ResetPlayerCash(playerid);
    GivePlayerCash(playerid,            pStats[playerid][pCash]);
    SetPlayerScore(playerid,            pStats[playerid][pLevel]);
    //SetPlayerWantedLevel(playerid,      pStats[playerid][pWantedLevel]);

	if(pStats[playerid][pDuty] == 0) {
		SetPlayerSkin(playerid,             pStats[playerid][pSkin]);
	    SetPlayerHealth(playerid,           pStats[playerid][pHealth] + 1.0);
	    SetPlayerArmour(playerid,           pStats[playerid][pArmor]);
	}

    SetPlayerPos(playerid,              pStats[playerid][pPosX], pStats[playerid][pPosY], pStats[playerid][pPosZ]);
    SetPlayerFacingAngle(playerid,      pStats[playerid][pPosA]);
	SetCameraBehindPlayer(playerid);
	
    SetPlayerColor(playerid, COLOR_WHITE);
	SetPlayerMapIcon(playerid, 0, 1172.0768, -1321.5231, 15.3990, 22, 1); // Hospital
	return true;
}


public _OnAntiCheatTick() // approx every 5 secs
{
    new string[128];

    foreach(Player, i) {
		if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK) {
			format(string, sizeof(string), "** [ANTI-CHEAT] Warnung: %s [ID: %d] könnte ein Jetpack benutzen.", _getName(i), i);
	        _sendAdminMessage(COLOR_RED, string, 0);

			format(string, sizeof(string), "[Jetpack-Warnung]: %s", _getName(i));
		    _logToFile("anti-cheat", string);
		}
	    else if(GetPlayerCash(i) < GetPlayerMoney(i)) { // buggy
                format(string, sizeof(string), "** [ANTI-CHEAT] Warnung: %s [ID: %d] könnte einen Geldcheat benutzen. (Geld 'erschaffen': $%d)", _getName(i), i, GetPlayerMoney(i));
                _sendAdminMessage(COLOR_RED, string, 0);

				format(string, sizeof(string), "[Geld-Warnung]: %s, 'erschaffenes' Geld: $%d", _getName(i), GetPlayerMoney(i));
			    _logToFile("anti-cheat", string);

                new const old_money = GetPlayerCash(i);
                ResetPlayerCash(i), GivePlayerCash(i, old_money);
		}
	    /*else if(pStats[playerid][pAdminLevel] < 1) {
	        if(GetPlayerPing(i) > MAX_PING) {
	            format(string, sizeof(string), "** %s wurde vom Server gekickt. Grund: Maximaler Ping überschritten. (%d, Maximum: %d)", _getName(playerid), playerid, GetPlayerPing(playerid), MAX_PING);
	            SendClientMessageToAll(COLOR_RED, string);
	            Kick(playerid);
	        }
	    }*/
	}
	return true;
}


public _OnWeatherChange(weatherid)
{
	if(weatherid == 0) for(weatherid = 0; weatherid < 10; weatherid++) weatherid = random(45);
	SetWeather(weatherid);
    return true;
}


//------------------------------------------------------------------------------ CUSTOM FUNCTIONS


public _sendAdminMessage(color, string[], requireduty)
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

public _sendFactionMessage(color, string[], factionid)
{
    foreach(Player, i) {
        if(pStats[i][pFaction] == factionid) SendClientMessage(i, color, string);
    }
    return true;
}

public _sendNearByMessage(playerid, Float:extraRadius, string[])
{
    new Float: PlayerX, Float: PlayerY, Float: PlayerZ;
    foreach(Player, i) {
        if(GetPVarInt(i, "Authentication") == 1) {
            GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
            if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i)) {
				//if(playerid == i)												return SendClientMessage(i, 0xE6E6E6E6, string);
				if(IsPlayerInRangeOfPoint(i, (3  * extraRadius), PlayerX, PlayerY, PlayerZ)) SendClientMessage(i, 0xE6E6E6E6, string);
	            else if(IsPlayerInRangeOfPoint(i, (6  * extraRadius), PlayerX, PlayerY, PlayerZ)) SendClientMessage(i, 0xAAAAAAAA, string);
	            else if(IsPlayerInRangeOfPoint(i, (9  * extraRadius), PlayerX, PlayerY, PlayerZ)) SendClientMessage(i, 0x8C8C8C8C, string);
	            else if(IsPlayerInRangeOfPoint(i, (12 * extraRadius), PlayerX, PlayerY, PlayerZ)) SendClientMessage(i, 0x6E6E6E6E, string);
			}
        }
    }
    return true;
}


public _setPlayerDuty(playerid, bool:status) {
	switch(status) {
		case true: {
			if(pStats[playerid][pFaction] == 1) {
				pStats[playerid][pDuty] = 1;
				SetPVarInt(playerid, "TazerAvailable", 1);
				SendClientMessage(playerid, COLOR_WHITE, "* Du hast dir die Arbeitskleidung angezogen.");
			}
		}
		
		case false: {
			if(pStats[playerid][pFaction] == 1) {
				pStats[playerid][pDuty] = 0;
				SetPVarInt(playerid, "TazerAvailable", 0);
				SendClientMessage(playerid, COLOR_WHITE, "* Du hast dir die Arbeitskleidung ausgezogen.");
			}
		}
	}
	_OnMySQLPlayerDataSave(playerid);
	SpawnPlayer(playerid);
	return true;
}


public _resetPlayerDataArray(playerid)
{
    pStats[playerid][pUsername]     	= -1;
    pStats[playerid][pPassword]     	= -1;
    pStats[playerid][pEmail]        	= -1;
    pStats[playerid][pIPAddress]    	= -1;
    pStats[playerid][pJustRegistered]	= -1;
    pStats[playerid][pAdminLevel]   	= -1;
    pStats[playerid][pFaction]      	= -1;
    pStats[playerid][pFactionRank]  	= -1;
    pStats[playerid][pDuty]  			= -1;
    pStats[playerid][pWantedLevel]  	= -1;
    pStats[playerid][pJob]		        = -1;
    pStats[playerid][pCash]         	= -1;
    pStats[playerid][pBank]         	= -1;
    pStats[playerid][pLevel]        	= -1;
    pStats[playerid][pSkin]         	= -1;
    pStats[playerid][pHealth]       	= -1;
    pStats[playerid][pArmor]        	= -1;
    pStats[playerid][pPosX]   			= -1;
    pStats[playerid][pPosY]   			= -1;
    pStats[playerid][pPosZ]    			= -1;
    pStats[playerid][pPosA]    			= -1;
    pStats[playerid][pLogins]       	= -1;
    pStats[playerid][pWarns]        	= -1;
    pStats[playerid][pWarning1]     	= -1;
    pStats[playerid][pWarning2]     	= -1;
    pStats[playerid][pWarning3]     	= -1;
    pStats[playerid][pBanstamp]  		= -1;
    pStats[playerid][pVeh1]         	= -1;
    pStats[playerid][pVeh2]         	= -1;
    pStats[playerid][pVeh3]         	= -1;
    pStats[playerid][pLicenseCar]   	= -1;
    pStats[playerid][pLicenseBike]  	= -1;
    pStats[playerid][pLicenseAir]   	= -1;

    SetPVarInt(playerid, "Authentication", 0);
    SetPVarInt(playerid, "LoggingOut", 0);
    SetPVarInt(playerid, "JustLogged", 1);
    SetPVarInt(playerid, "PlayerMuted", 0);
	SetPVarInt(playerid, "TazerAvailable", 0);

    TogglePlayerSpectating(playerid, false);
    return true;
}


public _resetTazerAvailability(playerid)	return SetPVarInt(playerid, "TazerAvailable", 1);
public _unfreezePlayer(playerid) 			return TogglePlayerControllable(playerid, true);
public _clearTextSpam(playerid) 			return SetPVarInt(playerid, "TextSpam", 0);
public _clearCommandSpam(playerid) 			return SetPVarInt(playerid, "CommandSpam", 0);


public _OnObjectsCreate()
{
	// LSPD
	CreateObject(8569, 1514.59961, -1659.89941, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59961, -1677.7998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59961, -1695.69922, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59961, -1713.59961, 9.6, 0, 0, 359.995);
	CreateObject(17522, 1577.09998, -1754.40002, 1.1, 0, 90, 359);
	CreateObject(1675, 1413.09998, -1715.90002, 5.1, 0, 272, 354);
	CreateObject(8569, 1494.59961, -1718.39941, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1494.59998, -1700.5, 9.6, 0, 0, 359.995);
	CreateObject(10032, 1508, -1691.09998, 12.4, 0, 0, 270);
	CreateObject(8569, 1494.59961, -1682.59961, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1494.59961, -1664.69922, 9.6, 0, 0, 359.995);
	CreateObject(3934, 1564.40002, -1658.30005, 27.4, 0, 0, 0);
	CreateObject(3934, 1564.5, -1646, 27.4, 0, 0, 0);
	CreateObject(970, 1506.69995, -1722.5, 12.9, 0, 0, 0);
	CreateObject(970, 1510.90002, -1722.5, 12.9, 0, 0, 0);
	CreateObject(970, 1515.09998, -1722.5, 12.9, 0, 0, 0);
	CreateObject(970, 1519.30005, -1722.5, 12.9, 0, 0, 0);
	CreateObject(970, 1506.5, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1510.69995, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1514.90002, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1522.30005, -1722.5, 12.9, 0, 0, 0);
	CreateObject(970, 1522.90002, -1724, 12.9, 0, 0, 44.75);
	CreateObject(671, 1507.5, -1724.90002, 12.3, 0, 0, 0);
	CreateObject(671, 1519.69995, -1724.69995, 12.4, 0, 0, 0);
	CreateObject(671, 1513.09998, -1724.69995, 12.3, 0, 0, 0);
	CreateObject(803, 1522.09998, -1723.5, 12, 0, 0, 112);
	CreateObject(803, 1516.90002, -1724.59998, 12.5, 0, 0, 86);
	CreateObject(803, 1509.80005, -1724.80005, 12.7, 0, 0, 0);
	CreateObject(805, 1505.80005, -1725.80005, 13.4, 0, 0, 0);
	CreateObject(5428, 1520.59998, -1720.5, 11.3, 0, 0, 17.25);
	CreateObject(970, 1521, -1725.90002, 12.9, 0, 0, 44.747);
	CreateObject(970, 1517.5, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1504.5, -1724.59998, 12.9, 0, 0, 267.5);
	CreateObject(970, 1504.5, -1725.40002, 12.9, 0, 0, 267.495);
	CreateObject(647, 1505.40002, -1726.69995, 12, 0, 0, 114);
	CreateObject(970, 1496.80005, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1492.59998, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1490.5, -1725.30005, 12.9, 0, 0, 270);
	CreateObject(970, 1490.5, -1721.09998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1716.90002, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1712.69995, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1708.5, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1704.30005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1700.09998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1695.90002, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1686.5, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1683.30005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1679.09998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1674.90002, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1670.69995, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1666.5, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1662.30005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1490.5, -1658.09998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1492.59998, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1496.7998, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1501, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1505.19995, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1509.40002, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1513.59998, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1517.80005, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1522, -1656, 12.9, 0, 0, 179.995);
	CreateObject(970, 1524.40002, -1720.40002, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1716.19995, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1712, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1707.80005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1703.59998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1699.40002, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1695.19995, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1691, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1686.80005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1524.40002, -1682.59998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1519.90002, -1658.09998, 12.9, 0, 0, 269.995);
	CreateObject(970, 1519.90002, -1662.30005, 12.9, 0, 0, 269.995);
	CreateObject(970, 1519.90002, -1666.5, 12.9, 0, 0, 269.995);
	CreateObject(970, 1522, -1668.59998, 12.9, 0, 0, 179.995);
	CreateObject(1257, 1521.09998, -1665.59998, 13.7, 0, 0, 180);
	CreateObject(1229, 1524, -1655.90002, 15, 0, 0, 154);
	CreateObject(2942, 1520.40002, -1656.40002, 13, 0, 0, 90.25);
	CreateObject(1346, 1520.80005, -1662.19995, 13.7, 0, 0, 90.75);
	CreateObject(8569, 1474.59961, -1718.39941, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1454.59998, -1718.40002, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59961, -1642, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59998, -1624.09998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1514.59998, -1606.30005, 9.6, 0, 0, 359.995);
	CreateObject(8168, 1546.69995, -1633.30005, 14.2, 0, 0, 197);
	CreateObject(968, 1544.69995, -1630.69995, 13.2, 0, 269.5, 270);
	CreateObject(970, 1543.30005, -1637.90002, 13.6, 0, 0, 269.995);
	CreateObject(970, 1544.69995, -1620.5, 13.1, 0, 0, 269.995);
	CreateObject(969, 1584.30005, -1637.90002, 12.5, 0.25, 358.5, 0.007);
	CreateObject(8569, 1494.59998, -1606.30005, 9.6, 0, 0, 359.995);
	CreateObject(8068, 1407.90002, -1682.40002, 19.3, 0, 0, 0);
	CreateObject(2984, 1404.40002, -1705.09998, 13.9, 0, 0, 270);
	CreateObject(2984, 1405.80005, -1705.09998, 13.9, 0, 0, 269.495);
	CreateObject(2984, 1407.19995, -1705.09998, 13.9, 0, 0, 269.495);
	CreateObject(2984, 1404.40002, -1704.19995, 13.9, 0, 0, 270);
	CreateObject(8569, 1474.69995, -1606.30005, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1454.69995, -1606.30005, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1606.19995, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1624.09998, 9.6, 0, 0, 359.995);
	CreateObject(17950, 1544.30005, -1613.90002, 14.6, 0, 0, 270);
	CreateObject(17950, 1544.30005, -1606.19995, 14.6, 0, 0, 270);
	CreateObject(14826, 1544.19995, -1606.09998, 13.1, 0, 0, 0);
	CreateObject(1025, 1547.40002, -1616.90002, 12.9, 0, 348, 88);
	CreateObject(1165, 1541.40002, -1617.09998, 12.9, 0, 0, 301);
	CreateObject(14574, 1540.69995, -1614.19995, 13.6, 0, 0, 90.25);
	CreateObject(3465, 1604.09998, -1625.69995, 13.9, 0, 0, 270);
	CreateObject(1331, 1606.30005, -1636.69995, 13.6, 0, 0, 0);
	CreateObject(1332, 1604.30005, -1636.80005, 13.8, 0, 0, 0);
	CreateObject(640, 1523.69995, -1719.59998, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1713.90002, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1708, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1702.09998, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1696.09998, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1690.19995, 13.1, 0, 0, 0);
	CreateObject(640, 1523.69995, -1684.30005, 13.1, 0, 0, 0);
	CreateObject(3660, 1492, -1717.09998, 15, 0, 0, 270);
	CreateObject(18284, 1604.19995, -1617.5, 15.3, 0, 0, 359.75);
	CreateObject(3660, 1492, -1703.80005, 15, 0, 0, 269.995);
	CreateObject(3660, 1492, -1678.59998, 15, 0, 0, 269.995);
	CreateObject(3660, 1492, -1666.19922, 15, 0, 0, 269.995);
	CreateObject(18264, 1446.5, -1605.09998, 12.4, 0, 0, 0);
	CreateObject(17521, 1445, -1629.59998, 15.9, 0, 0, 270);
	CreateObject(10982, 1441.19995, -1669.40002, 18.4, 0, 0, 270);
	CreateObject(8569, 1444.5, -1659.90002, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1677.80005, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1700.5, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1718.40002, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1474.59998, -1700.59998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1464.5, -1700.5, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1474.59998, -1682.69995, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1454.59998, -1682.69995, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1682.59998, 9.6, 0, 0, 359.995);
	CreateObject(3465, 1604.19995, -1620.30005, 13.9, 0, 0, 270);
	CreateObject(3465, 1604.19995, -1614.80005, 13.9, 0, 0, 270);
	CreateObject(3465, 1604, -1609.5, 13.9, 0, 0, 270);
	CreateObject(3873, 1466.59998, -1703.09998, 29.7, 0, 0, 0);
	CreateObject(4021, 1453.69995, -1624.19995, 18.9, 0, 0, 89.995);
	CreateObject(8569, 1454.69995, -1611.09998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1474.59998, -1664.80005, 9.6, 0, 0, 359.995);
	CreateObject(5729, 1495.09998, -1607.90002, 14.7, 0, 0, 90);
	CreateObject(8569, 1494.59998, -1646.80005, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1494.59998, -1628.90002, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1474.69995, -1611.09998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1464, -1646.90002, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1474.59961, -1629, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1454.59961, -1664.7998, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1444.5, -1642, 9.6, 0, 0, 359.995);
	CreateObject(8569, 1454.59998, -1629, 9.6, 0, 0, 359.995);
	CreateObject(4638, 1518.09998, -1667.59998, 14.1, 0, 0, 180);
	CreateObject(640, 1521.59998, -1674.90002, 13.1, 0, 0, 91);
	CreateObject(640, 1515.90002, -1675, 13.1, 0, 0, 91);
	CreateObject(640, 1510.19995, -1675.09998, 13.1, 0, 0, 91);
	CreateObject(640, 1507.80005, -1677.5, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1683.30005, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1689, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1694.80005, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1700.5, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1706.30005, 13.1, 0, 0, 0);
	CreateObject(640, 1507.80005, -1712.09998, 13.1, 0, 0, 0);
	CreateObject(970, 1501, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(970, 1505.19995, -1727.40002, 12.9, 0, 0, 0);
	CreateObject(1361, 1490.59998, -1691.19995, 13.1, 0, 0, 0);
	CreateObject(4018, 1516.40002, -1622.59998, 12.4, 0, 0, 89.75);
	CreateObject(3660, 1502.30005, -1657.59998, 15, 0, 0, 180.245);
	CreateObject(970, 1488.40002, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1484.19995, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1480, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1475.80005, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1471.59998, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1467.40002, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1463.19995, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1459, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1454.80005, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(970, 1450.59998, -1674.90002, 12.9, 0, 0, 179.995);
	CreateObject(17526, 1480.09998, -1644.69995, 14.6, 0, 0, 180);
	CreateObject(989, 1470.5, -1621.30005, 14.2, 0, 0, 197.75);
	CreateObject(8569, 1494.69995, -1611, 9.6, 0, 0, 359.995);
	CreateObject(800, 1502.69995, -1654.69995, 14.5, 0, 0, 0);
	CreateObject(800, 1499, -1654.30005, 13.8, 0, 0, 0);
	CreateObject(800, 1496.40002, -1654.69995, 14.6, 0, 0, 0);
	CreateObject(800, 1493.09998, -1655, 14, 0, 0, 0);
	CreateObject(993, 1499.69995, -1650.80005, 14, 0, 0, 0);
	CreateObject(993, 1489.69995, -1650.80005, 14, 0, 0, 0);
	CreateObject(800, 1488.80005, -1668.80005, 13.8, 0, 0, 0);
	CreateObject(800, 1488.19995, -1673.19995, 14.3, 0, 0, 0);
	CreateObject(800, 1483, -1673.30005, 14.3, 0, 0, 0);
	CreateObject(800, 1478.09998, -1673.19995, 14, 0, 0, 0);
	CreateObject(800, 1473.40002, -1673.19995, 14.3, 0, 0, 0);
	CreateObject(800, 1468.59998, -1673.19995, 14, 0, 0, 0);
	CreateObject(800, 1463.90002, -1673.30005, 14, 0, 0, 0);
	CreateObject(800, 1459.09998, -1673.19995, 14, 0, 0, 0);
	CreateObject(800, 1454.30005, -1673.30005, 14, 0, 0, 0);
	CreateObject(800, 1450.30005, -1673.30005, 14, 0, 0, 0);
	CreateObject(1332, 1484.59998, -1666.30005, 13.5, 0, 0, 180);
	CreateObject(1333, 1482.40002, -1666.19995, 13.3, 0, 0, 0);
	CreateObject(1334, 1479.59998, -1666.40002, 13.5, 0, 0, 182);
	CreateObject(1344, 1477.30005, -1666.30005, 13.2, 0, 0, 0);
	CreateObject(992, 1470.69995, -1667.40002, 14, 0, 0, 89.5);
	CreateObject(1221, 1475.19995, -1666.5, 12.9, 0, 0, 0);
	CreateObject(1230, 1475.5, -1667.30005, 12.8, 0, 0, 0);
	CreateObject(1265, 1474.40002, -1666.19995, 12.9, 0, 0, 0);
	CreateObject(792, 1484.09998, -1724.09998, 12.8, 0, 0, 0);
	CreateObject(792, 1477.19995, -1724.09998, 12.8, 0, 0, 0);
	CreateObject(792, 1470.30005, -1724.09998, 12.8, 0, 0, 0);
	CreateObject(792, 1438.19995, -1695.90002, 12.8, 0, 0, 0);
	CreateObject(792, 1438.09998, -1702.69995, 12.8, 0, 0, 0);
	CreateObject(792, 1438.09998, -1710.09998, 12.8, 0, 0, 0);
	CreateObject(792, 1438, -1717.30005, 12.8, 0, 0, 0);
	CreateObject(792, 1438, -1724.19995, 12.8, 0, 0, 0);
	CreateObject(792, 1444.19995, -1724.30005, 12.8, 0, 0, 0);
	CreateObject(792, 1450.69995, -1724.19995, 12.8, 0, 0, 0);
	CreateObject(792, 1457.09998, -1724.09998, 12.8, 0, 0, 0);
	CreateObject(792, 1463.80005, -1724.09998, 12.8, 0, 0, 0);
	CreateObject(5822, 1577.19995, -1639.69995, 21, 0, 0, 273);
	CreateObject(910, 1446.80005, -1637.90002, 13.7, 0, 0, 87.75);
	CreateObject(854, 1447.40002, -1645.30005, 12.5, 0, 0, 0);
	CreateObject(850, 1459.19995, -1639, 12.5, 0, 0, 0);
	CreateObject(2971, 1452.40002, -1638.19995, 12.4, 0, 0, 0);
	CreateObject(2968, 1453.69995, -1637.40002, 12.7, 0, 0, 0);
	CreateObject(2890, 1451.69995, -1649.09998, 12.4, 0, 0, 89.75);
	CreateObject(1441, 1456.09998, -1637.5, 13, 0, 0, 0);
	CreateObject(1440, 1447.80005, -1646.09998, 12.9, 0, 0, 160);
	CreateObject(1439, 1449.59998, -1637.19995, 12.4, 0, 0, 0);
	CreateObject(1438, 1452.30005, -1642.40002, 12.4, 0, 0, 0);
	CreateObject(1415, 1446.59998, -1640.09998, 12.5, 0, 0, 88);
	CreateObject(1372, 1446.69995, -1642.30005, 12.4, 0, 0, 88.75);
	CreateObject(1349, 1452.09998, -1640.69995, 12.9, 356.002, 177.995, 355.86);
	CreateObject(1265, 1456.09998, -1646.69995, 12.9, 0, 0, 0);
	CreateObject(1264, 1457, -1646.19995, 12.9, 0, 0, 0);
	CreateObject(2673, 1456.09998, -1643.59998, 12.5, 0, 0, 0);
	CreateObject(2671, 1451, -1645.19995, 12.4, 0, 0, 0);
	CreateObject(1413, 1460.19995, -1643.30005, 13.7, 0, 0, 89);
	CreateObject(1413, 1457.5, -1647.30005, 13.7, 0, 0, 0);
	CreateObject(1413, 1452.19995, -1647.30005, 13.7, 0, 0, 0);
	CreateObject(1413, 1446.90002, -1647.30005, 13.7, 0, 0, 0);
	CreateObject(1364, 1487.59998, -1676.59998, 13.2, 0, 0, 0);
	CreateObject(1364, 1481, -1676.5, 13.2, 0, 0, 0);
	CreateObject(1364, 1474.59998, -1676.5, 13.2, 0, 0, 0);
	CreateObject(1364, 1468.30005, -1676.40002, 13.2, 0, 0, 0);
	CreateObject(1364, 1462.30005, -1676.40002, 13.2, 0, 0, 0);
	CreateObject(1364, 1455.90002, -1676.40002, 13.2, 0, 0, 0);
	CreateObject(1364, 1450.30005, -1676.30005, 13.2, 0, 0, 0);
	CreateObject(792, 1453, -1676.09998, 12.4, 0, 0, 0);
	CreateObject(792, 1458.90002, -1676.19995, 12.4, 0, 0, 0);
	CreateObject(792, 1465.40002, -1676, 12.4, 0, 0, 0);
	CreateObject(792, 1471.5, -1676.30005, 12.4, 0, 0, 0);
	CreateObject(792, 1477.80005, -1676.5, 12.4, 0, 0, 0);
	CreateObject(792, 1484.40002, -1676.40002, 12.4, 0, 0, 0);
}


public _OnPlayerObjectsCreate(playerid)
{
	// LSPD
	RemoveBuildingForPlayer(playerid, 4031, 1460.0547, -1725.9922, 9.2031, 0.25);
	RemoveBuildingForPlayer(playerid, 4054, 1402.5000, -1682.0234, 25.5469, 0.25);
	RemoveBuildingForPlayer(playerid, 4057, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 4138, 1536.1406, -1743.6875, 6.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 4210, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1457.9375, -1620.6953, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1266, 1538.5234, -1609.8047, 19.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 1266, 1565.4141, -1722.3125, 25.0391, 0.25);
	RemoveBuildingForPlayer(playerid, 4229, 1597.9063, -1699.7500, 30.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 4230, 1597.9063, -1699.7500, 30.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 4236, 1387.0313, -1715.0234, 30.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 1261, 1413.6328, -1721.8203, 28.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1496.8672, -1707.8203, 13.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 4235, 1387.0313, -1715.0234, 30.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 1267, 1413.6328, -1721.8203, 28.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.6250, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1467.9844, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1485.1719, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 3981, 1460.0547, -1725.9922, 9.2031, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1713.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1716.7031, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1505.1797, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1713.7031, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1289, 1504.7500, -1711.8828, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1704.7656, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1702.3594, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 4005, 1402.5000, -1682.0234, 25.5469, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1676.6875, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1692.2344, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1656.2500, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1636.2344, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1445.8125, -1650.0234, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1619.0547, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.7266, -1710.0625, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.6563, -1707.6875, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1704.6406, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1701.5703, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1702.5313, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.5547, -1697.2891, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1694.0469, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1692.3906, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 4186, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.1250, -1687.5625, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1690.6484, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1458.6172, -1684.1328, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.2734, -1666.2969, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1682.7188, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1471.4063, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1682.3125, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1458.2578, -1659.2578, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1449.8516, -1655.9375, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1477.9375, -1652.7266, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.6094, -1653.2500, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.3516, -1650.5703, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1454.4219, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.8516, -1646.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.8984, -1651.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1465.9375, -1639.8203, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1466.4688, -1637.9609, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1449.5938, -1635.0469, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.7109, -1632.8906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8906, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.6641, -1627.8828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.4688, -1626.0234, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 3985, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 4206, 1479.5547, -1639.6094, 13.6484, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8359, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1466.4844, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.3359, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1471.3516, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1704.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1494.2109, -1694.4375, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1693.7344, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1496.9766, -1686.8516, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1494.1406, -1689.2344, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1682.6719, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1480.6094, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1488.2266, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.4063, -1651.3906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.3672, -1646.3828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1493.1328, -1639.4531, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.1797, -1627.7656, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.2188, -1632.6797, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.4141, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.3594, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1488.5313, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1498.0547, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1288, 1504.7500, -1705.4063, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1287, 1504.7500, -1704.4688, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1286, 1504.7500, -1695.0547, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1285, 1504.7500, -1694.0391, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.9609, -1684.6094, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.1641, -1662.0156, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.7188, -1670.9219, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1503.1875, -1621.1250, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1501.2813, -1624.5781, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.3594, -1616.9688, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1504.8906, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1508.4453, -1668.7422, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1505.6953, -1654.8359, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1508.5156, -1647.8594, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1513.2734, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1510.8906, -1607.3125, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 4030, 1536.1406, -1743.6875, 6.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 1260, 1565.4141, -1722.3125, 25.0391, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1721.6328, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1705.2734, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1693.9688, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1688.0859, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1673.7109, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1668.0781, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1647.6406, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1621.9609, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1525.3828, -1611.1563, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1260, 1538.5234, -1609.8047, 19.8438, 0.25);
}


//------------------------------------------------------------------------------ YCMD COMMANDS


// admin commands ascending
// adminlevel 1
YCMD:ahelp(playerid, params[], help)
{
#pragma unused params
    Command_AddAltNamed("ahelp", "ah");
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

	if(pStats[playerid][pAdminLevel] >= 1)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 1: /adminduty /say /showmembers");
	if(pStats[playerid][pAdminLevel] >= 2)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 2: /spawnveh /respawnveh /respawnaveh /repairveh");
	if(pStats[playerid][pAdminLevel] == 3)  SendClientMessage(playerid, COLOR_PURPLE, "** Level 3: /makeadmin /motd /set /announce");
    return true;
}


YCMD:adminduty(playerid, params[], help)
{
#pragma unused params
    new string[128];

    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

    if(GetPVarInt(playerid, "AdminDuty") == 0) {
        SetPVarInt(playerid, "AdminDuty", 1);
        format(string, sizeof(string), "** Administrator %s [ID: %d] ist nun On-Duty.", _getName(playerid), playerid);
        GetPlayerHealth(playerid, pStats[playerid][pHealth]);
        SetPlayerHealth(playerid, 999999999.99);
        SetPlayerColor(playerid, COLOR_PURPLE);
    }
    else if(GetPVarInt(playerid, "AdminDuty") == 1) {
        SetPVarInt(playerid, "AdminDuty", 0);
        format(string, sizeof(string), "** Administrator %s [ID: %d] ist nun Off-Duty.", _getName(playerid), playerid);
        SetPlayerHealth(playerid, 100.0);
        SetPlayerColor(playerid, COLOR_WHITE);
    }
    SendClientMessageToAll(COLOR_PURPLE, string);
    _logToFile("admin", string);
    return true;
}


YCMD:say(playerid, params[], help)
{
    new string[128];
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /say [Nachricht]");

    format(string, sizeof(string), "** Admin %s: %s", _getName(playerid), params);
    SendClientMessageToAll(COLOR_PURPLE, string);

	format(string, sizeof(string), "** Admin %s [/say]: %s", _getName(playerid), params);
    _logToFile("admin", string);
    return true;
}


YCMD:showmembers(playerid, params[], help)
{
    new string[128], val, coordstring[2048];
    if(pStats[playerid][pAdminLevel] < 1)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "d", val))              	return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /showmembers [FraktionsID]");
														//evtl. noch Fraktionen auflisten

 	new temp[25], rows, fields;

	format(querystring, sizeof(querystring), "SELECT `username`, `factionRank` FROM `accounts` WHERE `faction` = %d", val);
	mysql_function_query(MYSQL_DBHANDLE, querystring, true, "", "");

    cache_get_data(rows, fields);
	printf("rows: %d", rows); // buggy

	_clearChat(playerid);
	new name[29], factionrank; // array
	for(new i = 0; i < rows; i++) {
	    cache_get_field_content(i, "username", 			temp), strcat(name, temp, 25);
	    cache_get_field_content(i, "factionRank", 		temp), factionrank = strval(temp);
		format(string, sizeof(string), "Name: %s, Rang: %d \r\n", name, factionrank);
		strcat(coordstring, string, sizeof(coordstring));
	}

	switch(val) {
		case 1: {
			SendClientMessage(playerid, COLOR_PURPLE, "*** Fraktionsmitglieder der Polizei ***");
			SendClientMessage(playerid, COLOR_WHITE, coordstring);
		}
		case 2: {
			SendClientMessage(playerid, COLOR_PURPLE, "*** Fraktionsmitglieder der Ärzte ***");
			SendClientMessage(playerid, COLOR_PURPLE, coordstring);
		}
		case 3: {
			SendClientMessage(playerid, COLOR_PURPLE, "*** Fraktionsmitglieder der Fahrschule ***");
			SendClientMessage(playerid, COLOR_PURPLE, coordstring);
		}
		case 4: {
			SendClientMessage(playerid, COLOR_PURPLE, "*** Fraktionsmitglieder des ADAC ***");
			SendClientMessage(playerid, COLOR_PURPLE, coordstring);
		}
		case 5: {
			SendClientMessage(playerid, COLOR_PURPLE, "*** Fraktionsmitglieder der Taxifahrer ***");
			SendClientMessage(playerid, COLOR_PURPLE, coordstring);
		}
	}
    return true;
}


//adminlevel 2
YCMD:spawnveh(playerid, params[], help)
{
    new val, color1, color2, string[128];
    new Float:X, Float:Y, Float:Z, Float:A;
    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "iii", val, color1, color2))                      return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /spawnveh [VehikelID] [Farbe1] [Farbe2]");

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

	format(string, sizeof(string), "** Administrator %s hat sich ein Vehikel mit der ID %d gespawned.", _getName(playerid), val);
    _logToFile("admin", string);
	return true;
}


YCMD:respawnveh(playerid, params[], help)
{
#pragma unused params

    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerInAnyVehicle(playerid))         return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);
    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	return true;
}


YCMD:respawnaveh(playerid, params[], help)
{
#pragma unused params

    new bool:VehicleUsed[MAX_VEHICLES] = false, string[128];

    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);

    foreach(Player, i) if(IsPlayerInAnyVehicle(i)) VehicleUsed[GetPlayerVehicleID(i)] = true;
    for(new v = 1; v != MAX_VEHICLES; v++) if(VehicleUsed[v] == false) SetVehicleToRespawn(v);

    format(string, sizeof(string), "** Administrator %s hat alle unbenutzten Vehikel zurückgesetzt.", _getName(playerid), playerid);
    SendClientMessageToAll(COLOR_PURPLE, string);
    _logToFile("admin", string);
	return true;
}


/*YCMD:test(playerid, params[], help)
{
#pragma unused params
	ResetUnusedDBVehicles();
}*/


YCMD:repairveh(playerid, params[], help)
{
    new string[128], giveplayerid;
    if(pStats[playerid][pAdminLevel] < 2)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "u", giveplayerid))                   return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /repairveh [SpielerID]"),
            														SendClientMessage(playerid, COLOR_WHITE, "Function: Will repair the specified players vehicle - health and body.");
    if(GetPVarInt(giveplayerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_ID_NOTONLINE);
    if(!IsPlayerInAnyVehicle(giveplayerid))             return SendClientMessage(playerid, COLOR_RED, "** Dieser Spieler ist in keinem Vehikel.");

    RepairVehicle(GetPlayerVehicleID(giveplayerid));
    PlayerPlaySound(giveplayerid, 1133, -1, -1, -1);

    format(string, sizeof(string), "** Administrator %s hat dein Vehikel repariert.", _getName(playerid));
    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Du hast das Vehikel von %s repariert.", _getName(giveplayerid));
    SendClientMessage(playerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Administrator %s hat das Vehikel von %s repariert.", _getName(playerid), _getName(giveplayerid));
    _logToFile("admin", string);
	return true;
}


/*YCMD:saveveh(playerid, params[], help)
{
    new Color1, Color2, Float:PositionX, Float:PositionY, Float:PositionZ, Float:AngleZ;
    new vehicleid = GetPlayerVehicleID(playerid);
    new ModelID = GetVehicleModel(vehicleid);

    if(pStats[playerid][pAdminLevel] < 3)										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerInAnyVehicle(playerid))											return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_NOVEHICLE);

    GetVehiclePos(vehicleid, PositionX, PositionY, PositionZ);
    GetVehicleZAngle(vehicleid, AngleZ);
	GetVehicleColor(vehicleid, Color1, Color2);

	format(querystring, sizeof(querystring), "INSERT INTO `vehicles` (model, posX, posY, posZ, angle, color1, color2) VALUES(%d, %f, %f, %f, %f, %d, %d)", ModelID, PositionX, PositionY, PositionZ, AngleZ, Color1, Color2);
	mysql_query(query);
	return true;
}


YCMD:deleteveh(playerid, params[], help)
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
YCMD:makeadmin(playerid, params[], help)
{
    new giveplayerid, val, string[128];
    if(pStats[playerid][pAdminLevel] < 3)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(!IsPlayerAdmin(playerid))       			return SendClientMessage(playerid, COLOR_RED, "** Dazu ist ein RCON Login notwendig.");
    if(sscanf(params, "ud", giveplayerid, val))           return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /makeadmin [SpielerID] [Level (1-3)]");
    if(val == pStats[giveplayerid][pAdminLevel])      return SendClientMessage(playerid, COLOR_RED, "** Dieser Spieler besitzt bereits dieses AdminLevel.");

    pStats[giveplayerid][pAdminLevel] = val;
    _OnMySQLPlayerDataSave(giveplayerid);

    format(string, sizeof(string), "** %s hat dein AdminLevel auf %d gesetzt.", _getName(playerid), val);
    SendClientMessage(giveplayerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Du hast das AdminLevel von %s [ID: %d] auf %d gesetzt.", _getName(giveplayerid), giveplayerid, val);
    SendClientMessage(playerid, COLOR_PURPLE, string);

    format(string, sizeof(string), "** Administrator %s hat das AdminLevel von %s auf %d gesetzt.", _getName(playerid), _getName(giveplayerid), giveplayerid, val);
	_logToFile("admin", string);
    return true;
}


YCMD:motd(playerid, params[], help)
{
    new string[128];
    if(pStats[playerid][pAdminLevel] < 3)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /motd [Nachricht]"),

    format(string, sizeof(string), "\r\n%s\r\n", params);
    ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "MOTD", string, "OK", " ");

	format(querystring, sizeof(querystring), "UPDATE `configuration` SET `motd` = '%s' WHERE `motd` = '%s'", params, sConfig[motd]);
	mysql_function_query(MYSQL_DBHANDLE, querystring, false, "", "");

    strdel(sConfig[motd], 0, sizeof(sConfig[motd])), strcat(sConfig[motd], params, sizeof(sConfig[motd]));

    format(string, sizeof(string), "MOTD geändert: %s", sConfig[motd]);
    SendClientMessageToAll(COLOR_WHITE, string);
    return true;
}


YCMD:set(playerid, params[], help)
{
    new string[128], param[16], giveplayerid, val;

	if(pStats[playerid][pAdminLevel] < 3) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "us[16]d", giveplayerid, param, val))                             return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /set [SpielerID] [Parameter] [Wert]"),
            																					SendClientMessage(playerid, COLOR_GREY, "* Parameter: Health, Armor, Interior, (V)irtual(W)orld, Skin, Cash, Level, Faction, Rank");

	if(strcmp(param, "health", true) == 0) {
        SetPlayerHealth(giveplayerid, val);
        pStats[giveplayerid][pHealth] = val;

        format(string, sizeof(string), "** Du hast die HP von %s auf %d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat deine HP auf %d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat die HP von %s auf %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

    else if(strcmp(param, "armor", true) == 0) {
        SetPlayerArmour(giveplayerid, val);
        pStats[giveplayerid][pArmor] = val;

        format(string, sizeof(string), "** Du hast die Rüstung von %s auf %d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat deine Rüstung auf %d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat die Rüstung von %s auf %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

    else if(strcmp(param, "interior", true) == 0) {
        SetPlayerInterior(giveplayerid, val);

        format(string, sizeof(string), "** Du hast den Interior von %s auf %d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat dein Interior auf %d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** %s hat den Interior von %s auf %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

    else if(strcmp(param, "vw", true) == 0 || strcmp(param, "virtualworld", true) == 0) {
        SetPlayerVirtualWorld(giveplayerid, val);

        format(string, sizeof(string), "** Du hast die virtuelle Welt von %s auf %d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat deine virtuelle Welt auf %d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** %s hat die virtuelle Welt von %s auf %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

    else if(strcmp(param, "skin", true) == 0) {
        SetPlayerSkin(giveplayerid, val);
        pStats[giveplayerid][pSkin] = val;

        format(string, sizeof(string), "** Du hast %s den Skin mit der ID %d gegeben.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat dir den Skin mit der ID %d gegeben.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** %s hat den Skin von %s auf ID %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

    else if(strcmp(param, "cash", true) == 0) {
        SetPVarInt(giveplayerid, "pMoney", GetPlayerMoney(playerid));
        GivePlayerCash(giveplayerid, -(GetPVarInt(giveplayerid, "pMoney")));
        GivePlayerCash(giveplayerid, val);
        pStats[giveplayerid][pCash] = val;

        format(string, sizeof(string), "** Du hast das Geld von %s auf $%d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat dein Geld auf $%d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "[SET] %s - $%d - %s.", _getName(playerid), val, _getName(giveplayerid));
    	_logToFile("money", string);

		format(string, sizeof(string), "** %s hat das Geld von %s auf $%d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }
    
    else if(strcmp(param, "level",  true) == 0) {
        SetPlayerScore(giveplayerid, val);
        pStats[giveplayerid][pLevel] = val;

        format(string, sizeof(string), "** Du hast das Level von %s auf %d gesetzt.", _getName(giveplayerid), val);
        SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat dein Level auf %d gesetzt.", _getName(playerid), val);
		SendClientMessage(giveplayerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** %s hat das Level von %s auf %d gesetzt", _getName(playerid), _getName(giveplayerid), val);
    	_logToFile("admin", string);
    }

	else if(strcmp(param, "faction",  true) == 0) {
        pStats[giveplayerid][pFaction] = val;

		switch(val) {
			case 1: {
				format(string, sizeof(string), "** Du hast %s der Fraktion Polizei zugeordnet.", _getName(giveplayerid));
		        SendClientMessage(playerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat dich der Fraktion Polizei zugeordnet.", _getName(playerid));
				SendClientMessage(giveplayerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat %s der Fraktion Polizei zugeordnet.", _getName(playerid), _getName(giveplayerid));
	    		_logToFile("admin", string);
			}
			case 2: {
				format(string, sizeof(string), "** Du hast %s der Fraktion Arzt zugeordnet.", _getName(giveplayerid));
		        SendClientMessage(playerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat dich der Fraktion Arzt zugeordnet.", _getName(playerid));
				SendClientMessage(giveplayerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat %s der Fraktion Arzt zugeordnet.", _getName(playerid), _getName(giveplayerid));
	    		_logToFile("admin", string);
			}
			case 3: {
			    format(string, sizeof(string), "** Du hast %s der Fraktion Fahrschule zugeordnet.", _getName(giveplayerid));
		        SendClientMessage(playerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat dich der Fraktion Fahrschule zugeordnet.", _getName(playerid));
				SendClientMessage(giveplayerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat %s der Fraktion Fahrschule zugeordnet.", _getName(playerid), _getName(giveplayerid));
	    		_logToFile("admin", string);
			}
			case 4: {
			    format(string, sizeof(string), "** Du hast %s der Fraktion ADAC zugeordnet.", _getName(giveplayerid));
		        SendClientMessage(playerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat dich der Fraktion ADAC zugeordnet.", _getName(playerid));
				SendClientMessage(giveplayerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat %s der Fraktion ADAC zugeordnet.", _getName(playerid), _getName(giveplayerid));
	    		_logToFile("admin", string);
			}
			case 5: {
				format(string, sizeof(string), "** Du hast %s der Fraktion Taxifahrer zugeordnet.", _getName(giveplayerid));
		        SendClientMessage(playerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat dich der Fraktion Taxifahrer zugeordnet.", _getName(playerid));
				SendClientMessage(giveplayerid, COLOR_PURPLE, string);

				format(string, sizeof(string), "** %s hat %s der Fraktion Taxifahrer zugeordnet.", _getName(playerid), _getName(giveplayerid));
	    		_logToFile("admin", string);
			}
			default: return SendClientMessage(playerid, COLOR_PURPLE, "** Ungültige Fraktions-ID.");
		}
        SpawnPlayer(giveplayerid);
    }

    else if(strcmp(param, "rank",  true) == 0) {
        pStats[giveplayerid][pFactionRank] = val;

		format(string, sizeof(string), "** Du hast %s den Rang %d seiner Fraktion gegeben.", _getName(giveplayerid), val);
       	SendClientMessage(playerid, COLOR_PURPLE, string);

		format(string, sizeof(string), "** Administrator %s hat dir den Rang %d deiner Fraktion gegeben.", _getName(playerid), val);
        SendClientMessage(giveplayerid, COLOR_PURPLE, string);

        format(string, sizeof(string), "** %s hat %s den Rang %d seiner Fraktion gegeben.", _getName(playerid), val, _getName(giveplayerid));
   		_logToFile("admin", string);

		SpawnPlayer(giveplayerid);
    }
    else SendClientMessage(playerid, COLOR_PURPLE, "* Ungültiger Parameter.");
    _OnMySQLPlayerDataSave(giveplayerid);
    return true;
}


/*YCMD:giveweapon(playerid, params[], help)       <-- in /set integrieren
{
    new string[128], id, weapon, ammo;

    if(pStats[playerid][pAdminLevel] < 3) 										return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(sscanf(params, "udd", id, weapon, ammo))									return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /giveweapon [SpielerID] [WaffenID] [Munition]");

    GivePlayerWeapon(id, weapon, ammo);

    format(string, sizeof(string), "** Administrator %s hat dir die Waffe mit der ID %d gegeben.", _getName(playerid), weapon);
    SendClientMessage(id, COLOR_PURPLE, string);

format(string, sizeof(string), "** Du hast %s die Waffe mit der ID %d gegeben.", _getName(id), weapon);
SendClientMessage(playerid, COLOR_PURPLE, string);

format(string, sizeof(string), "** Administrator %s hat %s die Waffe mit der ID %d gegeben.", _getName(playerid), _getName(id), weapon);
return true;
}*/


YCMD:announce(playerid, params[], help)
{
    new string[128];

    if(pStats[playerid][pAdminLevel] < 3)       return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_ADMIN_CMD);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /(ann)ounce [Nachricht]");

	foreach(Player, i) _clearChat(i);

    format(string, sizeof(string), "*** WICHTIGE Ankündigung von Administrator %s ***", _getName(playerid));
    SendClientMessageToAll(COLOR_PURPLE, string);
    SendClientMessageToAll(COLOR_PURPLE, " ");
    format(string, sizeof(string), "%s", params);
    SendClientMessageToAll(COLOR_WHITE, string);
    SendClientMessageToAll(COLOR_PURPLE, " ");
    SendClientMessageToAll(COLOR_PURPLE, "**************************************************************");

	format(string, sizeof(string), "** Admin %s [/announce]: %s", _getName(playerid), params);
    _logToFile("admin", string);
    return true;
}


// player
YCMD:help(playerid, params[], help)
{
#pragma unused params
    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

    SendClientMessage(playerid, COLOR_OOC, "* Allgemein: /admins /afk /showme /givecash");
    SendClientMessage(playerid, COLOR_OOC, "* Chat:      /a /s /b /me /ooc");
    switch(pStats[playerid][pFaction]) {
		case 1: SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /duty /r(adio)");
		case 2: SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /duty /r(adio)");
		case 3: SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
		case 4: SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
		case 5: SendClientMessage(playerid, COLOR_OOC, "* Fraktion: ");
	}
    if(pStats[playerid][pFactionRank] == 5)	SendClientMessage(playerid, COLOR_OOC, "* Fraktion: /getfunds");
    return true;
}


YCMD:saveacc(playerid, params[], help)              // debug cmd
{
#pragma unused params
    _OnMySQLPlayerDataSave(playerid);
    SendClientMessage(playerid, COLOR_PURPLE, "**** DBG: Account saved.");
    return true;
}


YCMD:loadacc(playerid, params[], help)              // debug cmd
{
#pragma unused params
    _OnPlayerDataAssign(playerid);
    SendClientMessage(playerid, COLOR_PURPLE, "**** DBG: Account loaded.");
	return true;
}


YCMD:admins(playerid, params[], help)
{
#pragma unused params

    new string[128];
    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

    SendClientMessage(playerid, COLOR_WHITE, "---------------------------------------------------------------------------------------------------------------------------------" );
    foreach(Player, i) {
        if(pStats[i][pAdminLevel] >= 1) {
            if(GetPVarInt(i, "AdminDuty") == 0 && GetPVarInt(i, "AFKStatus") == 1) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [AFK] [Off-Duty]", _getName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else if(GetPVarInt(i, "AdminDuty") == 0 && GetPVarInt(i, "AFKStatus") == 0) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [Off-Duty]", _getName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else if(GetPVarInt(i, "AdminDuty") == 1 && GetPVarInt(i, "AFKStatus") == 1) {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d) [AFK]", _getName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_GREY, string);
            }
            else {
                format(string, sizeof(string), "* Administrator %s [ID: %d] (AdminLevel: %d)", _getName(i), i, pStats[i][pAdminLevel]);
                SendClientMessage(playerid, COLOR_WHITE, string);
            }
        }
        else SendClientMessage(playerid, COLOR_WHITE, "Es sind momentan keine Administratoren online.");
        SendClientMessage(playerid, COLOR_WHITE, "---------------------------------------------------------------------------------------------------------------------------------" );
    }
    return true;
}


YCMD:afk(playerid, params[], help)
{
#pragma unused params

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

	switch(GetPVarInt(playerid, "AFKStatus")) {
		case 0: {
	        SendClientMessage(playerid, COLOR_OOC, "* Du bist nun AFK.");
	        SetPVarInt(playerid, "AFKStatus", 1);
	        TogglePlayerControllable(playerid, false);
		}

		case 1: {
	        SendClientMessage(playerid, COLOR_OOC, "* Du bist nun nicht mehr AFK.");
	        SetPVarInt(playerid, "AFKStatus", 0);
	        TogglePlayerControllable(playerid, true);
		}
	}
    return true;
}


YCMD:showme(playerid, params[], help)
{
    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);

	foreach(Player, i) {
		//dialog:
		// case white: SetPlayerMarkerForPlayer(i, playerid, COLOR_WHITE);
		// case ultraviolettwithstripes: SetPlayerMarkerForPlayer(i, playerid, COLOR_ultraviolettwithstripes);
	}
	SendClientMessage(playerid, COLOR_OOC, "* Du hast deine Anzeigefarbe geändert. Cooler Typ.");
	return true;
}


YCMD:adminchat(playerid, params[], help)
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /a(dminchat) [Nachricht]");

	if(pStats[playerid][pAdminLevel] >= 1) {
        format(string, sizeof(string), "[ ** %s: %s ]", _getName(playerid), params);
        _sendAdminMessage(COLOR_PURPLE, string, false);

       	format(string, sizeof(string), "[ADMIN] %s: %s", _getName(playerid), params);
    	_logToFile("chat", string);
	}
	else {
        format(string, sizeof(string), "[ ** %s [ID: %d]: %s ]", _getName(playerid), playerid, params);
        _sendAdminMessage(COLOR_RED, string, false);
        SendClientMessage(playerid, COLOR_RED, string);

       	format(string, sizeof(string), "[SUPPORT] %s: %s", _getName(playerid), params);
    	_logToFile("chat", string);
	}
    _logToFile("chat", string);
    return true;
}


YCMD:s(playerid, params[], help)
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /s [Nachricht]");

    format(string, sizeof(string), "%s schreit: %s!!", _getNameEx(playerid), params);
    _sendNearByMessage(playerid, 2.5, string);

    format(string, sizeof(string), "%s!!", params);
	SetPlayerChatBubble(playerid, string, COLOR_WHITE, 15.0, 4000);

	format(string, sizeof(string), "[S] %s schreit: %s!!", _getName(playerid), params);
    _logToFile("chat", string);
    return true;
}


YCMD:b(playerid, params[], help)
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /b [Nachricht]");

    format(string, sizeof(string), "(( %s: %s ))", _getNameEx(playerid), params);
    _sendNearByMessage(playerid, 1.0, string);

	format(string, sizeof(string), "[B] (( %s: %s ))", _getName(playerid), params);
    _logToFile("chat", string);
    return true;
}


YCMD:me(playerid, params[], help)
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /me [Aktion]");

    format(string, sizeof(string), "* %s %s", _getNameEx(playerid), params);
    _sendNearByMessage(playerid, 1, string);

	format(string, sizeof(string), "[ME] %s %s", _getName(playerid), params);
    _logToFile("chat", string);
    return true;
}


YCMD:ooc(playerid, params[], help)
{
    new string[128];

    if(GetPVarInt(playerid, "Authentication") != 1)                             return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(isnull(params))                          return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /o(oc) [Nachricht]");

    format(string, sizeof(string), "[OOC] %s: %s", _getNameEx(playerid), params);
    SendClientMessageToAll(COLOR_WHITE, string);

	format(string, sizeof(string), "[OOC] %s: %s", _getName(playerid), params);
    _logToFile("chat", string);
    return true;
}


YCMD:givecash(playerid, params[], help)
{
    new string[128], giveplayerid, amount, Float:posX, Float:posY, Float:posZ;

    if(GetPVarInt(giveplayerid, "Authentication") != 1) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_USER_NOTLOGGEDIN);
    if(sscanf(params, "ud", giveplayerid, amount))      return SendClientMessage(playerid, COLOR_GREY,  "* Verwendung: /givecash [SpielerID] [Menge]");
    if(playerid == giveplayerid) {
		format(string, sizeof(string), "* %s holt eine Münze aus der Tasche und spielt damit.", _getName(playerid), _getName(giveplayerid));
		_sendNearByMessage(playerid, 1.0, string);
		return true;
	}
	if(GetPlayerCash(playerid) < amount) return SendClientMessage(playerid, COLOR_RED,  "* Du hast nicht genügend Geld.");
    GetPlayerPos(giveplayerid, posX, posY, posZ);
    if(!IsPlayerInRangeOfPoint(playerid, 8.0, posX, posY, posZ))                return SendClientMessage(playerid, COLOR_RED, "* Du bist zu weit von diesem Spieler entfernt.");

	GivePlayerCash(playerid, -amount);
    GivePlayerCash(giveplayerid, amount);

	format(string, sizeof(string), "* %s holt Geld aus der Tasche und gibt es %s.", _getName(playerid), _getName(giveplayerid));
   	_sendNearByMessage(playerid, 1.0, string);

	format(string, sizeof(string), "[GIVECASH] %s - $%d - %s.", _getName(playerid), amount, _getName(giveplayerid));
   	_logToFile("money", string);

    format(string, sizeof(string), "* Du hast %s $%d gegeben.", _getName(giveplayerid), amount);
    SendClientMessage(playerid, COLOR_OOC, string);

    format(string, sizeof(string), "* Du hast $%d von %s bekommen.", amount, _getName(playerid), playerid);
    SendClientMessage(giveplayerid, COLOR_OOC, string);
    return true;
}


// factions
YCMD:getfunds(playerid, params[], help)
{
	if(pStats[playerid][pFactionRank] != 5) return SendClientMessage(playerid, COLOR_RED, ERRORMESSAGE_FACTIONRANK_TOOLOW);

	new string[128];
	switch(pStats[playerid][pFaction]) {
		case 1: format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", sConfig[faction_1_funds]);
		case 2: format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", sConfig[faction_2_funds]);
 		case 3: format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", sConfig[faction_3_funds]);
  		case 4: format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", sConfig[faction_4_funds]);
   		case 5: format(string, sizeof(string), "* Momentan befinden sich $%d in der Fraktionskasse.", sConfig[faction_5_funds]);
	}
	SendClientMessage(playerid, COLOR_OOC, string);
	return true;
}


YCMD:duty(playerid, params[], help)
{
	if(pStats[playerid][pFaction] == 0 || pStats[playerid][pFaction] > 2) return SendClientMessage(playerid, COLOR_RED, "* Deine Fraktion besitzt keine Arbeitskleidung.");
	switch(pStats[playerid][pFaction]) {
		case 1: {
			//if(!IsPlayerInRangeOfPoint(playerid, 3.0, posX, posY, posZ)) return SendClientMessage(playerid, COLOR_RED, "* Dazu musst du in der Umkleidekabine sein.");
			switch(pStats[playerid][pDuty]) {
				case 0: _setPlayerDuty(playerid, true);
				case 1: _setPlayerDuty(playerid, false);
			}
		}
		case 2: {
			//if(!IsPlayerInRangeOfPoint(playerid, 3.0, posX, posY, posZ)) return SendClientMessage(playerid, COLOR_RED, "* Dazu musst du in der Umkleidekabine sein.");
			switch(pStats[playerid][pDuty]) {
				case 0: _setPlayerDuty(playerid, true);
				case 1: _setPlayerDuty(playerid, false);
			}
		}
	}
	return true;
}


/*
YCMD:radio(playerid, params[], help)
{
	new freq, string[128];
    if(sscanf(params, "us[128]d", giveplayerid, param, val))                     return SendClientMessage(playerid, COLOR_GREY, "* Verwendung: /radio [Frequenz] [Text]"),
                                                                                	    SendClientMessage(playerid, COLOR_GREY, "* Frequenz ist ein optionaler Parameter.");

	format(string, sizeof(string, "[RADIO] %s: %s", _getName(playerid), params);
	_sendFactionMessage(COLOR_WHITE, string, 1),
	return true;
}

*/


