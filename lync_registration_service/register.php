<?php
	include 'common.php';

	$userId = null;
	if(!empty($_POST["userId"])){
		$userId = mysql_real_escape_string($_POST["userId"]);
	}	
	
	if(!empty($userId)){
		
		$link = db_connect();	
			
		// Performing SQL query
		$query = sprintf("insert into devices (user_id) values ('%s')", $userId);
		$result = mysql_query($query);
		if(!$result){
			echo '{"error" : "Cannot execute SQL: ['.$query.']: '.mysql_error(). '"}';
			exit();//die('Could not connect: ' . mysql_error());
		}

		echo '{"status" : "OK"}';

		db_clean($link);
	}
	else{
		echo '{"error" : "UserId is empty"}';
	}
?>