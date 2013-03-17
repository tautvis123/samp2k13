/*

-- samp2k13 include
-- Function: outsource small functions
-- by Harti (17-03-2013)

*/


stock Log2File(filename[], string[])
{
	new str[256], str2[256];
	new year, month, day, hour, minute, second;

	getdate(year, month, day);
	gettime(hour, minute, second);
	
    format(str, sizeof(str), "[%02d:%02d:%02d]: %s\r\n", hour, minute, second, string);
    format(str2, sizeof(str2), "logs/%d-%02d-%02d-%s.log", year, day, month, filename);

    new File:hFile;
    hFile = fopen(str2, io_append);
    fwrite(hFile, str);
    fclose(hFile);
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


stock timec(timestamp, compare = -1) // http://forum.sa-mp.com/showthread.php?t=254915
{
    if (compare == -1) compare = gettime();

    new n, Float:d = (timestamp > compare) ? timestamp - compare : compare - timestamp, returnstr[32];
    if (d < 60) {
        format(returnstr, sizeof(returnstr), "< 1 Minute");
        return returnstr;
    }
	else if (d < 3600) { // 3600 = 1 hour
        n = floatround(floatdiv(d, 60.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "Minute");
    }
	else if (d < 86400) { // 86400 = 1 day
        n = floatround(floatdiv(d, 3600.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "Stunde");
    }
	else if (d < 2592000) { // 2592000 = 1 month
        n = floatround(floatdiv(d, 86400.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "Tag");
    }
	else if (d < 31536000) { // 31536000 = 1 year
        n = floatround(floatdiv(d, 2592000.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "Monat");
    }
	else {
        n = floatround(floatdiv(d, 31536000.0), floatround_floor);
        format(returnstr, sizeof(returnstr), "Jahr");
    }
    if (n == 1) format(returnstr, sizeof(returnstr), "1 %s", returnstr);
	else format(returnstr, sizeof(returnstr), "%d %ss", n, returnstr);
    return returnstr;
}


stock ClearChat(playerid)
{
	for(new i = 0; i < 10; i++) SendClientMessage(playerid, 0xFFFFFF, " ");
}


stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) GetPlayerName(playerid, name, sizeof(name));
    else name = "Unbekannt";
    return name;
}


stock GetEscName(playerid)
{
    new EscapedName[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) {
        GetPlayerName(playerid, name, sizeof(name));
        mysql_real_escape_string(name, EscapedName);
    }
    else EscapedName = "Unbekannt";
    return EscapedName;
}


stock GetNameEx(playerid)
{
    new str[24], String[128];
    GetPlayerName(playerid, String, 24);
    strmid(str, String, 0, strlen(String), 24);
    for(new i = 0; i < MAX_PLAYER_NAME; i++) if (str[i] == '_') str[i] = ' ';
    return str;
}