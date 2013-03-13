<?php 
	include_once("config.php");
?>

<?php if( !(isset( $_POST['register'] ) ) ) { ?>


<!DOCTYPE html>
<html>
    <head>
        <title>SSRP UCP</title>
        <link rel="stylesheet" type="text/css" href="style.css" />
    </head>
    
    <body>
        <header id="head" >
        	<p>SSRP UCP Registration</p>
        	<p><a href="register.php"><span id="register">Registration</span></a></p>
        </header>
        
        <div id="main-wrapper">
        	<div id="register-wrapper">
            	<form method="post">
                	<ul>
                    	<li>
                        	<label for="usn">Benutzername : </label>
                        	<input type="text" id="usn" maxlength="30" required autofocus name="username" />
                    	</li>
                    
                    	<li>
                        	<label for="passwd">Passwort : </label>
                        	<input type="password" id="passwd" maxlength="30" required name="password" />
                    	</li>
                        
                        <li>
                        	<label for="conpasswd">Passwort : </label>
                        	<input type="password" id="conpasswd" maxlength="30" required name="conpassword" />
                    	</li>
                        <li>
                        	<label for="eml">Email : </label>
                        	<input type="email" id="email" maxlength="30" required name="email" />
                    	</li>
                    	<li class="buttons">
                        	<input type="submit" name="register" value="Register" />
                            <input type="button" name="cancel" value="Cancel" onclick="location.href='index.php'" />
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
	
	if( $_POST['password'] == $_POST['conpassword'] ) {
		echo $usr->register($_POST);	
	} else {
		echo "Die Passwörter stimmen nicht überein!";	
	}
}
?>