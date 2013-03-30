<?php
if(empty($_SESSION["user"]))
{
?><center>
<form action="index.php?page=login" method="post">
<table id="login">
	<tr><td><?php // echo $logi1lng; ?>
		<input type="text" name="username" value="Username" onFocus="if(this.value=='Username') this.value=''"
		onBlur="if(this.value==''){this.value='Username'}" autocomplete="off" maxlength="16" style="width: 150px" /></td></tr>
	<tr><td><?php //echo $logi2lng; ?>
		<input type="password" name="password" value="Password" onFocus="if(this.value=='Password') this.value=''"
		onBlur="if(this.value==''){this.value='Password'}" autocomplete="off" maxlength="20" style="width: 150px" /></td></tr>
	<tr><td><input type="submit" value="<?php echo "Login"; ?>" style="width: 150px"></td></tr>
</table>
</form></center>
<?php
}
else{
echo'';}
?>