/*

-- samp2k13 include
-- .. created to outsource small functions
-- by Harti (17-03-2013)

*/


stock _logToFile(filename[], string[])
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


stock _getVehicleType(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 400 .. 402, 404 .. 416, 418 .. 424, 426 .. 429, 431 .. 434, 436 .. 439, 442 .. 445, 451, 455, 457 .. 459, 466, 467, 470, 471, 474, 475, 477 .. 480, 482, 483, 485, 486, 489 .. 492, 494 .. 496, 498 .. 500, 502 .. 508, 514 .. 518, 524 .. 536, 539 .. 547, 549 .. 552, 554 .. 562, 565 .. 568, 571 .. 576, 578 .. 580, 582, 583, 585, 587 .. 589, 596 .. 605, 609:
			return 0; // CAR
		case 403, 440, 456:
			return 1; // TRUCK
		case 481, 509, 510: 
			return 2; // BIKE
		case 448, 461 .. 463, 468, 521 .. 523, 581, 586:
			return 3; // MOT					ORBIKE
		case 430, 446, 452 .. 454, 472, 473, 484, 493, 595:
			return 4; // BOAT
		case 460, 476, 511 .. 513, 519, 520, 553, 577, 592, 593: 
			return 5; // PLANE
		case 441, 464, 465, 501, 564, 594: 
			return 6; // RC
		case 449, 537, 538, 569, 570, 590: 
			return 7; // TRAIN
		case 435, 450, 584, 591, 606 .. 608, 610, 611: 
			return 8; // TRAILER
		case 417, 425, 447, 469, 487, 488, 497, 548, 563: 
			return 9; // HELI
	}
	return -1;
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


stock _getVehiclePanelDamageStatus(vehicleid, &FrontLeft, &FrontRight, &RearLeft, &RearRight, &WindShield, &FrontBumper, &RearBumper)  // http://forum.sa-mp.com/showpost.php?p=689837&postcount=10
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	FrontLeft 	= Panels & 15;
	FrontRight 	= Panels >> 4 & 15;
	RearLeft	= Panels >> 8 & 15;
	RearRight 	= Panels >> 12 & 15;
	WindShield 	= Panels >> 16 & 15;
	FrontBumper = Panels >> 20 & 15;
	RearBumper 	= Panels >> 24 & 15;
	return true;
}


stock _getVehicleDoorDamageStatus(vehicleid, &Bonnet, &Boot, &FrontLeft, &FrontRight, &RearLeft, &RearRight)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	Bonnet 		= Doors & 7;
	Boot 		= Doors >> 8 & 7;
	FrontLeft 	= Doors >> 16 & 7;
	FrontRight 	= Doors >> 24 & 7;
	RearLeft 	= Doors >> 32 & 7;
	RearRight 	= Doors >> 40 & 7;
	return true;
}


stock _getVehicleLightDamageStatus(vehicleid, &First, &Second, &Third, &Fourth)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	First 		= Lights & 1;
	Second 		= Lights >> 1 & 1;
	Third 		= Lights >> 2 & 1;
	Fourth 		= Lights >> 3 & 1;
	return true;
}


stock _getVehicleTireDamageStatus(vehicleid, &FrontLeft, &FrontRight, &RearLeft, &RearRight)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	if(_getVehicleType(vehicleid) == 2 || _getVehicleType(vehicleid) == 3) return FrontLeft = Tires >> 1 & 1, FrontRight = Tires & 1; // BIKE & MOTORBIKE

	RearRight 	= Tires & 1;
	FrontRight 	= Tires >> 1 & 1;
	RearLeft 	= Tires >> 2 & 1;
	FrontLeft 	= Tires >> 3 & 1;
	return true;
}


stock _updateVehiclePanelDamageStatus(vehicleid, FrontLeft, FrontRight, RearLeft, RearRight, WindShield, FrontBumper, RearBumper)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	return UpdateVehicleDamageStatus(vehicleid, FrontLeft | (FrontRight << 4) | (RearLeft << 8) | (RearRight << 12) | (WindShield << 16) | (FrontBumper << 20) | (RearBumper << 24), Doors, Lights, Tires);
}


stock _updateVehicleDoorDamageStatus(vehicleid, Bonnet, Boot, FrontLeft, FrontRight, RearLeft, RearRight)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	return UpdateVehicleDamageStatus(vehicleid, Panels, Bonnet | (Boot << 8) | (FrontLeft << 16) | (FrontRight << 24) | (RearLeft << 32) | (RearRight << 40), Lights, Tires);
}


stock _updateVehicleLightDamageStatus(vehicleid, First, Second, Third, Fourth)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	return UpdateVehicleDamageStatus(vehicleid, Panels, Doors, First | (Second << 1) | (Third << 2) | (Fourth << 3), Tires);
}


stock _updateVehicleTireDamageStatus(vehicleid, FrontLeft, FrontRight, RearLeft, RearRight)
{
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(vehicleid, Panels, Doors, Lights, Tires);
	if(_getVehicleType(vehicleid) == 2 || _getVehicleType(vehicleid) == 3) return UpdateVehicleDamageStatus(vehicleid, Panels, Doors, Lights, FrontRight | (FrontLeft << 1));
	else return UpdateVehicleDamageStatus(vehicleid, Panels, Doors, Lights, RearRight | (FrontRight << 1) | (RearLeft << 2) | (FrontLeft << 3));
}


stock _clearChat(playerid)
{
	for(new i = 0; i < 10; i++) SendClientMessage(playerid, 0xFFFFFF, " ");
	return true;
}


stock _getName(playerid)
{
    new name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) GetPlayerName(playerid, name, sizeof(name));
    else name = "Unbekannt";
    return name;
}


stock _getEscName(playerid)
{
    new EscapedName[MAX_PLAYER_NAME], name[MAX_PLAYER_NAME];
    if(IsPlayerConnected(playerid)) {
        GetPlayerName(playerid, name, sizeof(name));
        mysql_real_escape_string(name, EscapedName);
    }
    else EscapedName = "Unbekannt";
    return EscapedName;
}


stock _getNameEx(playerid)
{
    new str[24], String[128];
    GetPlayerName(playerid, String, 24);
    strmid(str, String, 0, strlen(String), 24);
    for(new i = 0; i < MAX_PLAYER_NAME; i++) if (str[i] == '_') str[i] = ' ';
    return str;
}

