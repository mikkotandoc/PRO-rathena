-- Rune Tablet System (character-bound)
-- Apply to the main ragnarok database.

CREATE TABLE IF NOT EXISTS `rune_book` (
  `char_id` int(11) unsigned NOT NULL,
  `book_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`char_id`, `book_id`),
  KEY `char_id` (`char_id`)
) ENGINE=MyISAM;

CREATE TABLE IF NOT EXISTS `rune_set` (
  `char_id` int(11) unsigned NOT NULL,
  `set_id` int(11) unsigned NOT NULL,
  `grade` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `fail_count` smallint(5) unsigned NOT NULL DEFAULT '0',
  `equipped` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `reward_flags` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`char_id`, `set_id`),
  KEY `char_id` (`char_id`)
) ENGINE=MyISAM;

-- Existing installs: add reward_flags if missing (ignore error if already present)
-- ALTER TABLE `rune_set` ADD COLUMN `reward_flags` int(11) unsigned NOT NULL DEFAULT '0' AFTER `equipped`;
