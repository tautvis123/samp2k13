<?php
$query2 = mysql_query('SELECT * FROM accounts WHERE username="'.$_SESSION["user"].'" LIMIT 1');
while($PlayerInfo = mysql_fetch_array($query2))
{



	echo "<div style='padding-left:25px; padding-right:25px;'>";
	echo "<center><h1>Pers&ouml;nliche Informationen</h1></center>" . '<table><colgroup width=200 span=2></colgroup><tr><td>';
	echo '<center><img src="img/skins/Skin_'.$PlayerInfo['skin'].'.png"></center>';
	if($PlayerInfo['eingeloggt']) $status = "<b style='color:green;'>Online</b>";
	else $status = "<b style='color:red;'>Offline</b>";
	echo '</td><td align=center><h2>'.$_SESSION['user'].'</h2><br><b>Status:</b> '.$status.'<br><b>'.GetWanteds($PlayerInfo['wanteds']).'</b></td></td><td>'.$sig.'</td>
	</tr><hr><table><colgroup>
	<col width=100><col width=400><col 	width=200><col width=400></colgroup><tr>';
	if($PlayerInfo['level'] == -999) echo dataout("Level",$PlayerInfo['adminLevel'].' (Gebannt)');
	else echo dataout("Level",$PlayerInfo['level']);
	if($PlayerInfo['adminLevel'] > 0 && $PlayerInfo['level'] != -999) echo dataout("Admin Rang","".GetARang($PlayerInfo['adminLevel'])."");
	else echo dataout("Admin","Nein");
	echo '</tr><tr>';
	echo dataout("Fraktion",GetFrak($PlayerInfo['Faction']));
	echo dataout("Rang",GetRang($PlayerInfo['faction'],$PlayerInfo['factionRank']));
	echo '</tr><tr>';
	echo dataout("Warns",$PlayerInfo['warns'])."";
	echo "<tr><td><hr></td></tr><tr>";
	echo dataout("Geldb&ouml;rse","$".$PlayerInfo['cash']).dataout("Bank","$".$PlayerInfo['bank'])."</tr><tr><td><hr></td></tr><tr>";
	echo dataout("F&uuml;hrerschein",schein($PlayerInfo['licenseCar']))."</tr><tr>";
	echo dataout("Motorradschein",schein($PlayerInfo['licenseBike']))."</tr><tr>";
	echo dataout("LKW Schein",schein($PlayerInfo['licenseTruck']))."</tr><tr>";
	echo dataout("Flugschein",schein($PlayerInfo['licenseAir']))."</tr><tr>";
	echo '</tr></table></div>';}
?>