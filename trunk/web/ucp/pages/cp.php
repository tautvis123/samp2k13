<?php

if(isset($_POST["submit"]))
{
	if($passwort == strtoupper(hash("sha256", ($_POST["altespw"]))))
	{
		$aender = mysql_query("UPDATE accounts SET passwort='".strtoupper(hash("sha256", $_POST["newpw"]))."'");
		if($aender == true){
		echo '<h3><center>Passwort geändert!</center></h3>';}
		else{echo '<h3><center>Passwort ändern Fehlgeschlagen!</center></h3>';}
	}
	else{echo '<h3><center>Das aktuelle Passwort stimmt nicht überein!</center></h3>';}
}

if(!empty($_SESSION["user"]))
{
?>
<center>
		<center><div id="main_head">
		  <h3><font color="#000000 ">Passwort &auml;ndern</h3></div></font></center>
		<form action="index.php?page=changepw&pver=cp" method="post">
		Aktuelles Passwort:<br /><input name="altespw" type="password" /><br />
		Neues Passwort:<br /><input name="newpw" type="password" /><br />
		<input type="submit" name="submit" value="Ändern" />
		</form>
</center>
<?php
}
else
echo'<center><h2>Du bist nicht eingeloggt!</h2></center>';
?>