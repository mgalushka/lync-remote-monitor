<?php
	include 'config.php';
	header('Content-type: application/json');
	
	error_reporting(0);
	
	function db_connect(){
		
		if (!is_callable('mysql_connect')) {
            return $this->_setLastError("-1", "MySQL extension is not loaded", "mysql_connect");
			echo '{"error" : "MySQL extension is not loaded: mysql_connect"}';
        }
	
		// Connecting, selecting database
		$link = mysql_connect($mysql_url, 'root'/*, $mysql_password*/);
		if (!$link) {
			echo '{"error" : "Cannot connect to MySQL: '.mysql_error(). '"}';
			exit();//die('Could not connect: ' . mysql_error());
		}
		
		//echo 'Connected successfully';
		$db_selected = mysql_select_db('lync_monitor', $link);
		if(!$db_selected){
			echo '{"error" : "Cannot select MySQL database: ['.$mysql_db.']: '.mysql_error(). '"}';
			exit();//die('Cannot select MySQL database: ' . mysql_error());
		}
		
		return $link;
	}
	
	function db_clean($link){
		// Free resultset
		mysql_free_result($result);

		// Closing connection
		mysql_close($link);
	}
	
?>	