<?php

if(isset($_POST["submit"]))
{
	if($passwort == strtoupper(md5($_POST["altespw"])))
	{
		$aender = mysql_query("UPDATE accounts SET passwort='".strtoupper(md5($_POST["newpw"]))."'");
		if($aender == true){
		echo '<h3><center>Passwort geändert!</center></h3>';}
		else{echo '<h3><center>Passwort ändern Fehlgeschlagen!!</center></h3>';}
	}
	else{echo '<h3><center>Das Jetztige(Altes PW) stimmt nicht überein!</center></h3>';}
}

if(!empty($_SESSION["user"]))
{
?>
<center>
<table width="528" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td colspan="3" background="design/img/head.gif" width="528" height="28" align="left">
		</td>
		</tr>
		<tr>
		<td background="design/img/left.gif" width="27">
		</td>
		<td background="design/img/content.gif" width="470" align="left" style="vertical-align:top;"><center>
		<center><div id="main_head">
		  <h3><font color="#000000 ">Passwort &auml;ndern</h3></div></font></center>
		<form action="index.php?page=changepw&pver=cp" method="post">
		Aktuelles Passwort:<br /><input name="altespw" type="password" /><br />
		Neues Passwort:<br /><input name="newpw" type="password" /><br />
		<input type="submit" name="submit" value="Ändern" />
		</form>
		</td>
		<td background="design/img/right.gif" width="31">
		</td>
		</tr>
		<tr>
		<td colspan="3" width="528" height="29" background="design/img/foot.gif" style="vertical-align:top;">
		</tr>
</table>
</center>
<?php
}
else
echo'<center><h2>Du bist nicht eingeloggt!</h2></center>';
?>