<?php
//Remove the user's sessid cookie.
setcookie ("sessid", "", time() - 3600);
//Send the user to the index.
header('Location: index.php');
?>