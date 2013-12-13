<?php
	include 'config.php';
	header('Content-type: application/json');
	
	error_reporting(0);
	
	function db_connect(){
		// Connecting, selecting database
		$link = mysql_connect($mysql_host.':'.$mysql_port, $mysql_user, $mysql_password);
		if (!$link) {
			echo '{"error" : "Cannot connect to MySQL: '.mysql_error(). '"}';
			die('Could not connect: ' . mysql_error());
		}
		
		//echo 'Connected successfully';
		$db_selected = mysql_select_db($mysql_db);
		if(!$db_selected){
			echo '{"error" : "Cannot select MySQL database: '.mysql_error(). '"}';
			die('Cannot select MySQL database: ' . mysql_error());
		}
	}
	
	function db_clean($link){
		// Free resultset
		mysql_free_result($result);

		// Closing connection
		mysql_close($link);
	}
	
?>	