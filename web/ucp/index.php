<?php 
	include_once("config.php");
?>

<?php if( !(isset( $_POST['login'] ) ) ) { ?>

<!DOCTYPE html>
<html>
    <head>
        <title>SSRP UCP</title>
        <link rel="stylesheet" type="text/css" href="style.css" />
    </head>
    
    <body>
    
        <header id="head" >
        	<p>SSRP UCP Login</p>
        	<p><a href="register.php"><span id="register">Registration</span></a></p>
        </header>
        
        <div id="main-wrapper">
        	<div id="login-wrapper">
            	<form method="post" action="">
                	<ul>
                    	<li>
                        	<label for="usn">Benutzername : </label>
                        	<input type="text" maxlength="30" required autofocus name="username" />
                    	</li>
                    
                    	<li>
                        	<label for="passwd">Passwort : </label>
                        	<input type="password" maxlength="30" required name="password" />
                    	</li>
                    	<li class="buttons">
                        	<input type="submit" name="login" value="Log me in" />
                            <input type="button" name="register" value="Register" onclick="location.href='register.php'" />
                    	</li>
                    
                	</ul>
            	</form>
                
            </div>
        </div>
    
    </body>
</html>

<?php 
} else {
	$usr = new Users;
	$usr->storeFormValues( $_POST );
	
	if( $usr->userLogin() ) {
		echo "Willkommen";	
	} else {
		echo "Falscher/s Benutzername/Passwort";	
	}
}
?>