<?php
require('connection.php');

$_userName = $_REQUEST["user"];
$_passWord = $_REQUEST["pwd"];

$szEscapedUser = mysql_real_escape_string($_userName);
$szEscapedPass = mysql_real_escape_string($_passWord);

$szQuery = " ";

$szQuery = "SELECT * FROM accounts WHERE username = '" . $szEscapedUser . "' AND password = '" . $szEscapedPass . "'";

$_qResult = mysql_query($szQuery) or die(mysql_error());

if(mysql_num_rows($_qResult) != 0)
{
	//Fetch the user's info into $_qFetch to be used as an object to compare the password.
	$_qFetch = mysql_fetch_object($_qResult);

	//This will check if $_qFetch->pass and $szEscapedPass are the same.
	if(strcmp($_qFetch->password, $szEscapedPass) == 0)
	{
		//If true, execute Success() and header to the home.
		Success($szEscapedUser);
        header("Location: home.php");
	}
	else
	{
		//If false, send the user to index.
		header("Location: index.php");
	}
}
else
{
	//If there are no rows, return this.
	echo('Invalid username/password combination.');
}


function Success($charname)
{
	//Grab the IP and put it into $szIPBuffer
	$szIPBuffer = $_SERVER['REMOTE_ADDR'];
	
	//Generate a random Session ID, and store it in $szSessID
	$szSessID = substr(str_shuffle(str_repeat('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',20)),0,20);

	//Set the user's sessid cookie to the value generated above. This cookie expires in one hour.
	setcookie("sessid", $szSessID, time()+3600);

	//Query the session ID into MySQL!
    $szQuery = "INSERT INTO `ucpsessids` (sessid, name, ip) VALUES ('" . $szSessID . "', '" . $charname . "', '" . $szIPBuffer . "')";

	//Query the above formatted string.
    mysql_query($szQuery);

}
?>