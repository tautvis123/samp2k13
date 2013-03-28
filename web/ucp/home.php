<?php
require('connection.php');

$_userInfo = "";

if(!isset($_COOKIE['sessid'])) header('Location: index.php');

$_pQuery = "SELECT * FROM `ucpsessids` WHERE sessid = '" . $_COOKIE['sessid'] . "'";
$qResult = mysql_query($_pQuery);

while($qFetch = mysql_fetch_object($qResult))
{
	$_userInfo = $qFetch;
}

$_userName = $_userInfo->username;

$szQuery = "SELECT * FROM accounts WHERE username = '" . $_userName . "'";

$qResult = mysql_query($szQuery) or die(mysql_error());

$qFetch = mysql_fetch_object($qResult);

$_skin = "SELECT skin FROM accounts WHERE username = '" . $_userName . "'";
$_skinImage = 'display/SKINS/';
$_skinImage .= $_skin;
$_skinImage .= '.jpg';
echo '<img src="'.$_skinImage.'"/>'
?>

<form action="logout.php" method="post">     
<input type="submit" value="Logout">
</form>