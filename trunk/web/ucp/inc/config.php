<?php
session_start();
error_reporting(0);
$host = 'db4free.net'; //mysql host
$user = 'samp2k13'; //db user
$pass = 'db123456'; //db pass
$data = 'samp2013'; //db name
$connect = mysql_connect($host, $user, $pass);
mysql_select_db($data, $connect);
$title = 'SSRP User Control Panel'; //title
?>