<?php
$_Host = "db4free.net";
$_User = "samp2013ucp";
$_Pass = "db123456";
$_Database = "samp2k13ucp";

$_Connection = mysql_connect($_Host, $_User, $_Pass) or die(mysql_error());

mysql_select_db($_Database);
?>