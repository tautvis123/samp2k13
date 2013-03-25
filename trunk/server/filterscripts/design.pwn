/*

samp2k13 design filterscript
by Arne

*/

#include <a_samp>

forward _createTextdraws();
forward _createObjects();
forward _createPlayerObjects(playerid);
forward tachoupdate();
//Textdraws
new Text:armaturenbrett;
new Text:armaturenbrettbox;
new Text:treibstoff;
new Text:tacho;
new Text:tankanzeige;
new Text:kmhbalken[MAX_PLAYERS];
new Text:tankbalken[MAX_PLAYERS];
new Text:kmhzahl[MAX_PLAYERS];
new Text:tankzahl[MAX_PLAYERS];
new Text:kmstand[MAX_PLAYERS];


public OnFilterScriptInit()
{
	_createObjects();
	_createTextdraws();
	print("\r\n  * design loaded\r\n");
	SetTimer("tachoupdate", 1000, 1);
	return true;
}


public OnFilterScriptExit()
{
	return true;
}


public OnPlayerConnect(playerid)
{
	_createPlayerObjects(playerid);

	return true;
}

public _createTextdraws()
{
 	armaturenbrett = TextDrawCreate(314.000000, 346.000000, "Armaturenbrett");
	TextDrawAlignment(armaturenbrett, 2);
	TextDrawBackgroundColor(armaturenbrett, 255);
	TextDrawFont(armaturenbrett, 2);
	TextDrawLetterSize(armaturenbrett, 0.270000, 1.200000);
	TextDrawColor(armaturenbrett, -1);
	TextDrawSetOutline(armaturenbrett, 0);
	TextDrawSetProportional(armaturenbrett, 1);
	TextDrawSetShadow(armaturenbrett, 1);

	armaturenbrettbox = TextDrawCreate(314.000000, 356.000000, "                                                                                                                                ");
	TextDrawAlignment(armaturenbrettbox, 2);
	TextDrawBackgroundColor(armaturenbrettbox, 255);
	TextDrawFont(armaturenbrettbox, 1);
	TextDrawLetterSize(armaturenbrettbox, 0.250000, 2.200000);
	TextDrawColor(armaturenbrettbox, -1);
	TextDrawSetOutline(armaturenbrettbox, 0);
	TextDrawSetProportional(armaturenbrettbox, 0);
	TextDrawSetShadow(armaturenbrettbox, 1);
	TextDrawUseBox(armaturenbrettbox, 1);
	TextDrawBoxColor(armaturenbrettbox, 255);
	TextDrawTextSize(armaturenbrettbox, 176.000000, 156.000000);

	treibstoff = TextDrawCreate(240.000000, 401.000000, "Treibstoff:");
	TextDrawBackgroundColor(treibstoff, 255);
	TextDrawFont(treibstoff, 1);
	TextDrawLetterSize(treibstoff, 0.320000, 1.400000);
	TextDrawColor(treibstoff, -1);
	TextDrawSetOutline(treibstoff, 0);
	TextDrawSetProportional(treibstoff, 1);
	TextDrawSetShadow(treibstoff, 1);

	tacho = TextDrawCreate(240.000000, 359.000000, "KM/H:");
	TextDrawBackgroundColor(tacho, 255);
	TextDrawFont(tacho, 1);
	TextDrawLetterSize(tacho, 0.280000, 1.400000);
	TextDrawColor(tacho, -1);
	TextDrawSetOutline(tacho, 0);
	TextDrawSetProportional(tacho, 1);
	TextDrawSetShadow(tacho, 1);

	tankanzeige = TextDrawCreate(240.000000, 374.000000, "Tank:");
	TextDrawBackgroundColor(tankanzeige, 255);
	TextDrawFont(tankanzeige, 1);
	TextDrawLetterSize(tankanzeige, 0.320000, 1.400000);
	TextDrawColor(tankanzeige, -1);
	TextDrawSetOutline(tankanzeige, 0);
	TextDrawSetProportional(tankanzeige, 1);
	TextDrawSetShadow(tankanzeige, 1);

	for(new i = 0; i<MAX_PLAYERS; i++)
 	{
		kmhbalken[i] = TextDrawCreate(361.000000, 362.000000, "         ");
		TextDrawBackgroundColor(kmhbalken[i], 255);
		TextDrawFont(kmhbalken[i], 1);
		TextDrawLetterSize(kmhbalken[i], 0.589999, 0.099999);
		TextDrawColor(kmhbalken[i], -1);
		TextDrawSetOutline(kmhbalken[i], 0);
		TextDrawSetProportional(kmhbalken[i], 1);
		TextDrawSetShadow(kmhbalken[i], 1);
		TextDrawUseBox(kmhbalken[i], 1);
		TextDrawBoxColor(kmhbalken[i], -1);
		TextDrawTextSize(kmhbalken[i], 269.000000, 123.000000);

		tankbalken[i] = TextDrawCreate(361.000000, 377.000000, "         ");
		TextDrawBackgroundColor(tankbalken[i], 255);
		TextDrawFont(tankbalken[i], 1);
		TextDrawLetterSize(tankbalken[i], 0.589999, 0.099999);
		TextDrawColor(tankbalken[i], -1);
		TextDrawSetOutline(tankbalken[i], 0);
		TextDrawSetProportional(tankbalken[i], 1);
		TextDrawSetShadow(tankbalken[i], 1);
		TextDrawUseBox(tankbalken[i], 1);
		TextDrawBoxColor(tankbalken[i], -1);
		TextDrawTextSize(tankbalken[i], 269.000000, 123.000000);

		kmhzahl[i] = TextDrawCreate(361.000000, 361.000000, "Zahl");
		TextDrawBackgroundColor(kmhzahl[i], 255);
		TextDrawFont(kmhzahl[i], 1);
		TextDrawLetterSize(kmhzahl[i], 0.370000, 1.000000);
		TextDrawColor(kmhzahl[i], -1);
		TextDrawSetOutline(kmhzahl[i], 0);
		TextDrawSetProportional(kmhzahl[i], 1);
		TextDrawSetShadow(kmhzahl[i], 1);

		tankzahl[i] = TextDrawCreate(361.000000, 376.000000, "Zahl");
		TextDrawBackgroundColor(tankzahl[i], 255);
		TextDrawFont(tankzahl[i], 1);
		TextDrawLetterSize(tankzahl[i], 0.370000, 1.000000);
		TextDrawColor(tankzahl[i], -1);
		TextDrawSetOutline(tankzahl[i], 0);
		TextDrawSetProportional(tankzahl[i], 1);
		TextDrawSetShadow(tankzahl[i], 1);

		kmstand[i] = TextDrawCreate(240.000000, 388.000000, "KM-Stand:");
		TextDrawBackgroundColor(kmstand[i], 255);
		TextDrawFont(kmstand[i], 1);
		TextDrawLetterSize(kmstand[i], 0.320000, 1.400000);
		TextDrawColor(kmstand[i], -1);
		TextDrawSetOutline(kmstand[i], 0);
		TextDrawSetProportional(kmstand[i], 1);
		TextDrawSetShadow(kmstand[i], 1);
	}
	return true;
}

public _createObjects()
{
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
	CreateObject(970, 1543.30005, -1637.90002, 13.6, 0, 0, 269.995);
	CreateObject(970, 1544.69995, -1620.5, 13.1, 0, 0, 269.995);
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
	CreateObject(3109, 1584.09998, -1637.90002, 13.5, 0, 0, 90);
	CreateObject(983, 1580.90002, -1637.90002, 15.1, 0, 0, 90);

	CreateObject(3465, 1007.5, -936.40002, 42.6, 0, 0, 98.25);      // gas stations
	CreateObject(3465, 1000.40002, -937.29999, 42.6, 0, 0, 98.245);
	CreateObject(9193, 1012.5, -948.09998, 46.2, 0, 0, 0);
	CreateObject(7390, -2021.59998, 179.89999, 32.4, 0, 0, 70);
	CreateObject(3465, -2026.59998, 156.89999, 29.4, 0, 0, 0);
	return true;
}


public _createPlayerObjects(playerid)
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
	return true;
}

public tachoupdate()
{
        for(new i = 0; i<MAX_PLAYERS; i++)
        {
                new Float:speed_x,Float:speed_y,Float:speed_z,Float:final_speed,final_speed_int;
                new veh = GetPlayerVehicleID(i);
                GetVehicleVelocity(veh, speed_x, speed_y, speed_z);
                final_speed = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*120.0;
                final_speed_int = floatround(final_speed,floatround_round);
                new kmh_anzahl = final_speed_int;
                new kmh[3],tank[10];
                format(kmh, 10,"%d", kmh_anzahl);//TANKSYSTEM ANPASSEN
                format(tank, 10,"%d", 100);
                TextDrawSetString(kmhzahl[i], kmh);
                TextDrawSetString(tankzahl[i], tank);

        }
        return 1;
}
