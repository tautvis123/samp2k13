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
	return '<th align=right>'.$description.':</th><td align=left>'.$data.'</td>';
 }
 function dataoutah($modelid,$price,$kaufen)
 {
	return '<tr><th align=left>'.GetCarName($modelid).'</th><td align=center>$'.$price.'</td><td align=center><a href="index.php?page=auptade&id='.$modelid.'&price='.$price.'">'.$kaufen.'</a></td></tr>';
 }
 function dataoutfrak($name,$rang,$id,$rangid,$teamid)
 {
	return '<tr><td align=left>'.$name.'</td><td align=center>'.$rang.'</td><td align=center><a href="index.php?page=befoerden&id='.$id.'&rang='.$rangid.'&tid='.$teamid.'">Bef&ouml;dern</a></td><td align=center><a href="index.php?page=feuern&id='.$id.'&tid='.$teamid.'">Entlassen</a></td></tr>';
 }
 function dataoutloggedfrak($name,$rang)
 {
	return '<tr><td align=left><font color=green>'.$name.'</font></td><td align=center><font color=green>'.$rang.'</font></td><th align=center><a></a></th><th align=center><a></a></th></tr>';
 }
 function dataoutnlfrak($name,$rang,$rangid)
 {
 	if($rangid >= 3){
	return '<tr><th align=left><font color=blue>'.$name.'</font></th><th align=center><font color=blue>'.$rang.'</font></th><th align=center><a></a></th><th align=center><a></a></th></tr>';}
	else{
	return '<tr><td align=left>'.$name.'</td><td align=center>'.$rang.'</td><th align=center><a></a></th><th align=center><a></a></th></tr>';}
 }
 function dataoutlfrak($name,$rang)
 {
	return '<tr><th align=left><font color=blue>'.$name.'</font></th><th align=center><font color=blue>'.$rang.'</font></th><th align=center><a></a></th><th align=center><a></a></th></tr>';
 }
 function dataoutclfrak($name,$rang,$id,$rangid,$teamid)
 {
	return '<tr><th align=left><font color=blue>'.$name.'</font></th><th align=center><font color=blue>'.$rang.'</font></th><th align=center><a></a></th><td align=center><a href="index.php?page=feuern&id='.$id.'&tid='.$teamid.'&rang='.$rangid.'">Entlassen</a></td></tr>';
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
		case 6:$wanteds = "<img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'><img src='img/star.gif'>"; break;
	}
	
	return $wanteds;
 }
 
 function GetCarName($modelid)
 {
 	switch($modelid)
	{
		case 0:$modelid = "Kein Auto"; break;
		case 535:$modelid = "Slamvan"; break;
		case 560:$modelid = "Sultan"; break;
		case 562:$modelid = "Elegy"; break;
	}
	return $modelid;
 }
 function CreateCode($length) {
	$chars = "1234567890abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	$i = 0;
	$password = "";
	while ($i <= $length) {
		$password .= $chars{mt_rand(0,strlen($chars))};
		$i++;
	}
	return $password;
 }
 
 function GetCodeTyp($typ)
 {
 	switch($typ)
	{
		case 0:$typ = "Nicht mehr Nutzbar"; break;
		case 1:$typ = "2 Tage Premium"; break;
		case 2:$typ = "Ein Level Up"; break;
		case 3:$typ = "Neue Handy Nr"; break;
		case 4:$typ = "10 Coins Aufladung"; break;
		case 5:$typ = "$500.000 Ingame Geld"; break;
	}
	return $typ;
 }
 function CheckCode($code)
 {
 	$query = mysql_query('SELECT * FROM donate_codes WHERE code="'.$code.'"');
	if(mysql_num_rows($query) == 1)
	{
		while($codeinfo = mysql_fetch_array($query))
		{
			$ctyp = $codeinfo["typ"];
			if($ctyp >= 1){$color = 'green';}else{$color = 'red';}
			$checkedcode = '<h3><font color='.$color.'>'.$code.'</font></h3>';
		}
	}
	else{ $checkedcode = '<h3><font color=red>'.$code.'</font></h3>'; }
	return $checkedcode;
 }
 function CheckBWStat($bwstat)
 {
 	switch($bwstat)
	{
		case 0:
			$bwstat = "Abgelehnt";
			break;
		case 1:
			$bwstat = "Angenommen";
			break;
		case 2:
			$bwstat = "In Bearbeitung";
			break;
	}
	return $bwstat;
 }
 function GetBWAntwort($jein,$user,$bw)
 {
 	switch($jein)
	{
		case 0:$antwort = 'Hallo '.$user.',<br><br>Ihre Bewerbung als '.$bw.' wurde leider Abgelehnt!<br><br>Im Gruß,<br>Das System<br><br>Dies ist eine Automatisch Generierte Nachricht,<br> also bitte nicht drauf Antworten!'; break;
		case 1:$antwort = 'Hallo '.$user.',<br><br>Ihre Bewerbung als '.$bw.' wurde erfolgreich Angenommen!<br>Bitte Melden sie Sich bei dem Leader/Admin<br><br>Herzlichen Glückwunsch!<br>Im Gruß,<br>Das System ;)<br><br>Dies ist eine Automatisch Generierte Nachricht,<br> also bitte nicht drauf Antworten!'; break;
	}
	return $antwort;
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