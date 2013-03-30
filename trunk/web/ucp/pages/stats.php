<?php
$query2 = mysql_query('SELECT * FROM accounts WHERE username="'.$_SESSION["user"].'" LIMIT 1');
while($PlayerInfo = mysql_fetch_array($query2))
{
	echo "<div style='padding-left:25px; padding-right:25px;'><table>";
	echo "<h1>Pers&ouml;nliche Informationen</h1>";
	echo '<img src="img/skins/Skin_'.$PlayerInfo['skin'].'.png">'											.'</tr><tr>';
	echo dataout("Name:",$_SESSION['user'])																			.'</tr><tr>';
	if($PlayerInfo['banned'] > 0) echo dataout("Gebannt","".($PlayerInfo['banstamp'])."")					.'</tr><tr>';
	echo dataout("Wanteds:",GetWanteds($PlayerInfo['wantedLevel']))													.'</tr><tr>';
	if($PlayerInfo['loggedIn']) $status = "<b style='color:green;'>Online</b>"; else $status = "<b style='color:red;'>Offline</b>";
	echo dataout("Status:",$status)																			.'</tr><tr>';
	echo dataout("Level:",$PlayerInfo['level'])																."</tr><tr>";
	if($PlayerInfo['adminLevel'] > 0) echo dataout("Admin Rang:","".GetARang($PlayerInfo['adminLevel'])."")	."</tr><tr>";
	echo dataout("Fraktion:",GetFrak($PlayerInfo['faction']))												."</tr><tr>";
	echo dataout("Rang:",GetRang($PlayerInfo['faction'],$PlayerInfo['factionRank']))						."</tr><tr>";
	echo dataout("Warns:",$PlayerInfo['warns'])																."</tr><tr>";
	echo dataout("Geldb&ouml;rse:","$".$PlayerInfo['cash'])													."</tr><tr>";
	echo dataout("Bank:","$".$PlayerInfo['bank'])															."</tr><tr>";
	echo dataout("F&uuml;hrerschein:",schein($PlayerInfo['licenseCar']))									."</tr><tr>";
	echo dataout("Motorradschein:",schein($PlayerInfo['licenseBike']))										."</tr><tr>";
	echo dataout("LKW Schein:",schein($PlayerInfo['licenseTruck']))											."</tr><tr>";
	echo dataout("Flugschein:",schein($PlayerInfo['licenseAir']))											."</tr><tr>";
	echo '</table></div>';}
?>