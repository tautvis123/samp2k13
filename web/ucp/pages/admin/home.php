<?PHP
  if($adminrang >= 5) {
?>
<center>
<table width="528" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td colspan="3" background="design/img/head.gif" width="528" height="28" align="left">
		</td>
		</tr>
		<tr>
		<td background="design/img/left.gif" width="27">
		</td>
		<td background="design/img/content.gif" width="470" align="left" style="vertical-align:top;"><center>
		<!--- <center><div id="main_head"><h3><font  color="#000000 ">Metin2 Signatur Generator</h3></div></font></center> !--->
  <table border="0">
  	<center><div id="main_head"><h3><font color="#000000">SuchtStation Roleplay Admincenter</h3></div></font></center>
	</center>
    </table><br />
	<table align="center" width="500">
	<tr>
    <td align="center">&raquo; Verwaltung &laquo;</td>
	</tr>
	<tr>
    <td align="center"><a href="index.php?page=admin&a=news">News Verwalten</a></td>
	</tr>
	</center>
</table>
<div style="padding-left:25px; padding-right:25px;"><hr /></div>

		<td background="design/img/right.gif" width="31">
		</td>
		</tr>
		<tr>
		<td colspan="3" width="528" height="29" background="design/img/foot.gif" style="vertical-align:top;">
		</tr>
</table>
</center>
<?PHP
  }
  else {
    echo'<center><h2><p class="meldung">Sie sind nicht für diesen Bereich berechtigt.</p></h2></center>';
  }
  
?>