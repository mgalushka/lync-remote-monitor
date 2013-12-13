<?php
	include 'common.php';

	$userId = mysql_real_escape_string($_POST["userId"]);
	if(!empty($userId)){
		
		$link = db_connect();	
			
		// Performing SQL query
		$query = sprintf('insert into devices (user_id) values (%s)', $userId);
		$result = mysql_query($query);
		if(!$result){
			echo '{"error" : "Cannot execute SQL: '.mysql_error(). '"}';
			die('Could not connect: ' . mysql_error());
		}

		echo '{"status" : "OK"}';

		db_clean($link);
	}
	else{
		echo '{"error" : "UserId is empty"}';
	}
?>