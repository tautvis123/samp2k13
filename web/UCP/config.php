<?php
    //set off all error for security purposes
	error_reporting(E_ALL);
	

	//define some contstant
    define( "DB_DSN", "mysql:host=db4free.net;dbname=samp2013" );
    define( "DB_USERNAME", "samp2k13" );
    define( "DB_PASSWORD", "db123456" );
	define( "CLS_PATH", "class" );
	
	//include the classes
	include_once( CLS_PATH . "/user.php" );
	

?>