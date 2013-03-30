<?php
if(!empty($_SESSION["user"]))
{
session_unset();
echo'<meta http-equiv="refresh" content="0; url=index.php?page=home">
<center><a href="index.php?id=1">'.$logo1lng.'</a></center>';
}
else
echo'<font color="red">'.$logo2lng.'</font>';
?>