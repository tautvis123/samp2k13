<?php
// ---- Online Player ----
$anzahl = "SELECT * from accounts WHERE eingeloggt = '1'"; 
$anzahl2 = mysql_query($anzahl); 
$onlineplayer = mysql_num_rows($anzahl2); 
// ---- Ende ----
$query = mysql_query('SELECT * FROM accounts WHERE name="'.$_SESSION["user"].'"');
if(mysql_num_rows($query) == 1)
{
while($userinfos = mysql_fetch_array($query))
{
$level = $userinfos["level"];
$fraktion = GetFrak($userinfos["faction"]);
$rang = GetRang($userinfos["faction"],$userinfos["factionRank"]);
}
}

if($fraktion == "Zivilist"){
$finfos = 'Fraktion: '.$fraktion;
}
else{
$finfos = 'Fraktion: '.$fraktion.' | Rang: '.$rang;}
?>
<?php
if(empty($_SESSION["user"]))
{
?>
<div style="padding-left:25px; padding-top:5px;">
<form action="index.php?page=login" method="post">
		<input type="text" name="username" value="Username" onFocus="if(this.value=='Username') this.value=''"
		onBlur="if(this.value==''){this.value='Username'}" autocomplete="off" maxlength="30" style="width: 150px" />
		<input type="password" name="password" value="Password" onFocus="if(this.value=='Password') this.value=''"
		onBlur="if(this.value==''){this.value='Password'}" autocomplete="off" maxlength="30" style="width: 150px" />
		<input type="submit" value="<?php echo "Login"; ?>" style="width: 150px">
		<font style="padding-left:350px; font-size:14px; color:white;">Spieler Online: <?php echo $onlineplayer; ?></font>
</form>
</div>
<?php
}
else{
if($adminrang == 0){$admin="";}else{$admin=" Admin Rang: ".GetARang($adminrang);}
echo'<div style="padding-left:25px; padding-top:9px; font-size:13px; color:white;">';
echo 'Hallo '.$_SESSION["user"].' | Level: '.$level.' | '.$finfos.' | '.$admin;
echo'</div>';
}
?>