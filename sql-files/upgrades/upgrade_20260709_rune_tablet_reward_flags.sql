-- Optional: existing rune_set tables created before reward_flags
-- Run once; ignore error if column already exists.
ALTER TABLE `rune_set` ADD COLUMN `reward_flags` int(11) unsigned NOT NULL DEFAULT '0' AFTER `equipped`;
