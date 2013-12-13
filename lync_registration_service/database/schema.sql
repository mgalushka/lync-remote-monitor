CREATE TABLE `devices` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`user_id` VARCHAR(7) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `user_id_ind` (`user_id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2;
