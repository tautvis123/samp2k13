<?PHP
  if($adminrang>=5) 
  {
    $adminPath = "./pages/admin/";
    
    if(isset($_GET['a']) && !empty($_GET['a']))
    {
      if(file_exists($adminPath.$_GET['a'].".php")) 
      {
        include($adminPath.$_GET['a'].".php");
      }
      else {
        include($adminPath."home.php");
      }
    } else 
    {
      include($adminPath."home.php");
    }
  }
  else
  {
    echo'<center><h2><p class="meldung">Sie sind nicht für diesen Bereich berechtigt.</p></h2></center>';
  }
?>