<?php
//This if statement will redirect to home.php if the user is logged in/has the cookie "sessid" set.
if(isset($_COOKIE['sessid'])) header('Location: home.php');
?>

<form method="post" action="checkcreds.php">
	Login
	<br><br>
	Username:<br>
	<input name="user" class="form-login" type="text" title="Username" value="" size="30" maxlength="2048" /><br>
	Passwort:<br>
	<input name="pwd" type="password" class="form-login" title="Password" value="" size="30" maxlength="2048" />
	<br>
	<input type="submit" value="Login" />
</form>