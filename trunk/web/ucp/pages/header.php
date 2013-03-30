<?php
// ---- Online Player ----
$anzahl = "SELECT * from accounts WHERE loggedIn = '1'"; 
$anzahl2 = mysql_query($anzahl); 
$onlineplayer = mysql_num_rows($anzahl2); 
// ---- Ende ----
$query = mysql_query('SELECT * FROM accounts WHERE name="'.$_SESSION["user"].'"');
if(mysql_num_rows($query) == 1)
{
	while($userinfos = mysql_fetch_array($query))
	{
		$level = $userinfos["level"];
	}
}
?>
<?php
if(empty($_SESSION["user"]))
{
	echo 	'<div style="padding-left:25px; padding-top:5px;">';
	echo 	'<font style="padding-left:350px; font-size:14px; color:white;">Spieler Online:  '.$onlineplayer.'</font></div>';
}
else
{
	if($adminrang == 0){$admin="";}else{$admin=" Admin Rang: ".GetARang($adminrang);}
	echo	'<div style="padding-left:25px; padding-top:9px; font-size:13px; color:white;">';
	echo	'Hallo '.$_SESSION["user"].' | Level: '.$level.' | '.$admin.' ';
	echo 	'<font style="padding-left:350px; font-size:14px; color:white;">Spieler Online:  '.$onlineplayer.'</font></div>';
}
?>