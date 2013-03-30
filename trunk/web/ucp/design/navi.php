
<?php
	$psite = addslashes($_REQUEST["pver"]);
	$fsite = addslashes($_REQUEST["fver"]);
	$pnsite = addslashes($_REQUEST["fach"]);
	//Normale Seiten
	if($page == "login"){ $login = 'class="active"'; }
	if($page == "stats"){ $stats = 'class="active"'; }
	if($page == "admin"){ $asite = 'class="active"'; }
	if($page == "home"){ $home = 'class="active"'; }
	if($psite == "cp" or empty($psite)){$cp = 'class="active"';}
	
	if(empty($_SESSION["user"]))
	{
		echo'<div id="navigation">';
		echo '<a href="index.php?page=home" '.$home.' >Home</a>';
		echo '<a href="index.php?page=login" '.$login.'>Login</a>';
		echo'</div>';
	}
	else
	{
		echo'<div id="navigation">';
		echo '<a href="index.php?page=home" '.$home.' >Home</a>';
		echo '<a href="index.php?page=stats" '.$stats.' >Statistiken</a>';
		echo '<a href="index.php?page=cp" '.$pver.' >Passwort &auml;ndern</a>';
		if($adminrang >= 3){ echo '<a href="index.php?page=admin" '.$asite.' >Admin Panel</a>';}
		echo '<a href="index.php?page=logout">Logout</a>';
		echo'</div>';
	}
?>