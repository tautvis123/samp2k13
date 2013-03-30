<?php
 function captcha()
 {
	$len = 2;
    $possible="123456789";
    $str="";
    while(strlen($str)<$len) {
    $str.=substr($possible,(rand()%(strlen($possible))),1);
	}
	$str1 = $str;
	
	$len = 1;
    $possible="123456789";
    $str="";
    while(strlen($str)<$len) {
    $str.=substr($possible,(rand()%(strlen($possible))),1);
	}
	$str2 = $str;
	$_SESSION[$session_prefix."captcha"] = $str1 + $str2;
	$_SESSION["captcha"] = $_SESSION[$session_prefix."captcha"];
	return $str1.' + '.$str2;
 }
 
  function encode ( $string )
 {
	$string = base64_encode($string);
	$string = str_rot13($string);
	$string = strrev($string);
	$string = str_rot13($string);
	$string = strrev($string);
	$string = strrev($string);
	$string = base64_encode($string);
	return $string;
 }

 function decode ( $string )
 {
	$string = base64_decode($string);
	$string = strrev($string);
	$string = strrev($string);
	$string = str_rot13($string);
	$string = strrev($string);
	$string = str_rot13($string);
	$string = base64_decode($string);
	return $string;
 }
 
 function GetARang( $string )
 {
 	switch ($string)
	{
    case 1:
        $string = "Supporter";
        break;
    case 2:
        $string = "Moderator";
        break;
    case 3:
        $string = "Super-Mod";
        break;
	case 4:
		$string = "Administrator";
		break;
	case 5:
		$string = "Server Owner";
		break;
	case 6:
		$string = "Scripter";
		break;
	}
	return $string;
 }
 function GetFrak( $string )
 {
 	switch ($string)
	{
	case 0:
		$string = "Zivilist";
		break;
    case 1:
        $string = "Polizei";
        break;
    case 2:
        $string = "Arzt";
        break;
    case 3:
        $string = "Fahrschule";
        break;
	case 4:
		$string = "ADAC";
		break;
	case 5:
		$string = "Taxi";
		break;
	case 6:
		$string = "Rotten Rats";
		break;
	case 7:
		$string = "EastSideTakers";
		break;
	}
	return $string;
 }
 function GetRang($string1, $string2)
 {
 if($string1 == 0){
	switch ($string2)
	{
	case 0:
		$string2 = "Zivilist";
		break;
	}
	return $string2;}
 elseif($string1 == 1 or $string1 == 2 or $string1 == 3){
	switch ($string2)
	{
	case 0:
		$string2 = "Azubi";
		break;
	case 1:
   	    $string2 = "Mittlerer Dienst";
 		break;
   	case 2:
       	$string2 = "Gehobener Dienst";
       	break;
   	case 3:
       	$string2 = "Co-Leader";
       	break;
	case 4:
		$string2 = "Leader";
		break;
	}
	return $string2;}
 else{
	switch ($string2)
	{
	case 0:
		$string2 = "Möchtegern";
		break;
	case 1:
   	    $string2 = "Homie";
 		break;
   	case 2:
       	$string2 = "Gangster";
       	break;
   	case 3:
       	$string2 = "Rechte Hand";
       	break;
	case 4:
		$string2 = "Boss";
		break;
	}
	return $string2;}	
 }
 function dataout($description,$data)
 {
	return '<th align=right>'.$description.'</th><td align=left>'.$data.'</td>';
 }
 function schein($jain)
 {
 	switch($jain)
	{
		case 0:
			$jain = "Nicht Bestanden";
			break;
		case 1:
			$jain = "Bestanden";
			break;
	}
	return $jain;
 }
 
 function GetWanteds($wanteds)
 {
 	switch($wanteds)
	{
		case 0:$wanteds = ""; break;
		case 1:$wanteds = "<img src='img/star.gif'>"; break;
		case 2:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'>"; break;
		case 3:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'>"; break;
		case 4:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'>"; break;
		case 5:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'>"; break;
		case 6:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img 						src='img/star.gif'>"; break;
	}	
	return $wanteds;
 }
 
 function calcPages($gesEin,$aktSeite,$eSeite) {
    $output = array();
    $esQuote = ceil(($gesEin/$eSeite));
    if($aktSeite==0) {$aktSeite=1;}
    $startS = ($aktSeite*$eSeite)-$eSeite;
    $output[0]=$esQuote;
    $output[1]=$startS;
    return $output;
  }
  function checkInt($wert) {
    $checkit = preg_match("/^[0-9]+$/",$wert);
    if($checkit) {
      return true;
    }
    else {
      return false;
    }
  }
?>