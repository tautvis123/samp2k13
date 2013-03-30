<?php
include('./inc/config.php');
include('./inc/functions.php');
$page = addslashes($_REQUEST["page"]);
$user = addslashes($_REQUEST["username"]);
$pass = addslashes($_REQUEST["password"]);
if(empty($page)) $page="index";
$file = $page;
if(!empty($user) AND !empty($pass))
{$query = mysql_query('SELECT * FROM accounts WHERE username="'.$user.'" AND password="'.hash("sha256", $pass).'"');
if(mysql_num_rows($query) == 1)
{
$_SESSION["user"] = $user;
echo'<meta http-equiv="refresh" content="0; url=index.php?page=home">';
}
else $error = '<center>Username oder Passwort ist falsch.</center>';}

$query2 = mysql_query('SELECT * FROM accounts WHERE username="'.$_SESSION["user"].'"');
while($userinfos = mysql_fetch_array($query2))
{
$passwort = $userinfos["passwort"];
$adminrang = $userinfos["adminLevel"];
$bankgeld = $userinfos["bank"];
$eingeloggt = $userinfos["loggedIn"];
$level = $userinfos["level"];
$ffrak = $userinfos["faction"];
$frank = $userinfos["factionRank"];
}
// ---- Online Check ----
$online3 = "SELECT * from accounts WHERE loggedIn = '1' AND username='".$_SESSION["user"]."'"; 
$online2 = mysql_query($online3); 
$online = mysql_num_rows($online2); 
// ---- Ende ----

include('./design/head.php');
include('./design/navi.php');
include('./design/middle.tpl');

	if(file_exists('./pages/'.$file.'.php'))
	{
	include('./pages/'.$file.'.php');}
	if(!empty($error)) echo '<font color="red">'.$error.'</font>'; 
	
include('./design/foot.tpl');	
?>
