--
-- Macro Patrol logging tables (import into your main rAthena database)
-- Usage: mysql -u root -p ragnarok < sql-files/import/macro_patrol_log.sql
--

CREATE TABLE IF NOT EXISTS `macro_patrol_cycle` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cycle_time` datetime NOT NULL,
  `players_on_farm` smallint(5) unsigned NOT NULL DEFAULT 0,
  `eligible` smallint(5) unsigned NOT NULL DEFAULT 0,
  `challenged` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `manual_run` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `cycle_time` (`cycle_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `macro_patrol_challenge` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cycle_id` int(11) unsigned NOT NULL DEFAULT 0,
  `challenge_time` datetime NOT NULL,
  `account_id` int(11) unsigned NOT NULL DEFAULT 0,
  `char_id` int(11) unsigned NOT NULL DEFAULT 0,
  `char_name` varchar(24) NOT NULL DEFAULT '',
  `map` varchar(24) NOT NULL DEFAULT '',
  `base_level` smallint(5) unsigned NOT NULL DEFAULT 0,
  `job_level` smallint(5) unsigned NOT NULL DEFAULT 0,
  `source` enum('patrol','manual_test') NOT NULL DEFAULT 'patrol',
  `result` enum('pending','passed','timeout','incorrect','disconnect') NOT NULL DEFAULT 'pending',
  `result_time` datetime DEFAULT NULL,
  `jail_minutes` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `char_id` (`char_id`),
  KEY `cycle_id` (`cycle_id`),
  KEY `result` (`result`),
  KEY `challenge_time` (`challenge_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
