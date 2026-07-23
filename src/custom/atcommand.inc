// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

/**
 * Custom atcommand implementations.
 * Register new commands in atcommand_def.inc.
 **/

ACMD_FUNC(mall)
{
	uint16 mapindex;
	int16 m;

	nullpo_retr(-1, sd);

	if (sd->m >= 0 && strcmp(map_mapid2mapname(sd->m), "prt_mk") == 0) {
		clif_displaymessage(fd, "You are already at the Item Mall.");
		return 0;
	}

	mapindex = mapindex_name2idx("prt_mk", nullptr);
	if (!mapindex) {
		clif_displaymessage(fd, msg_txt(sd, 1)); // Map not found.
		return -1;
	}

	m = map_mapindex2mapid(mapindex);
	if (m < 0) {
		clif_displaymessage(fd, msg_txt(sd, 1)); // Map not found.
		return -1;
	}

	if ((map_getmapflag(m, MF_NOWARPTO) && !pc_has_permission(sd, PC_PERM_WARP_ANYWHERE)) || !pc_job_can_entermap((enum e_job)sd->status.class_, m, pc_get_group_level(sd))) {
		clif_displaymessage(fd, msg_txt(sd, 247)); // You are not authorized to warp to this map.
		return -1;
	}

	if (sd->m >= 0 && map_getmapflag(sd->m, MF_NOWARP) && !pc_has_permission(sd, PC_PERM_WARP_ANYWHERE)) {
		clif_displaymessage(fd, msg_txt(sd, 248)); // You are not authorized to warp from your current map.
		return -1;
	}

	if (pc_setpos(sd, mapindex, 114, 102, CLR_TELEPORT) != SETPOS_OK) {
		clif_displaymessage(fd, msg_txt(sd, 1)); // Map not found.
		return -1;
	}

	clif_displaymessage(fd, "Warping to the Item Mall...");
	return 0;
}

/**
 * Sends a compensation package to a player via RODEX.
 * Restricted to GM level 99 (super users).
 * Usage: @compensation <char name>
 **/
ACMD_FUNC(compensation)
{
	// Compensation package configuration. Adjust these to change the reward.
	const t_itemid compensation_item = 616; // Old Card Album
	const int16 compensation_amount = 1;

	map_session_data *pl_sd;
	struct mail_message msg;

	nullpo_retr(-1, sd);

	// Restrict usage to GM level 99 and above.
	if (pc_get_group_level(sd) < 99) {
		clif_displaymessage(fd, "You are not authorized to use this command.");
		return -1;
	}

	memset(atcmd_player_name, '\0', sizeof(atcmd_player_name));

	if (!message || !*message || sscanf(message, "%23[^\n]", atcmd_player_name) < 1) {
		clif_displaymessage(fd, "Please enter a player name (usage: @compensation <char name>).");
		return -1;
	}

	pl_sd = map_nick2sd(atcmd_player_name, true);
	if (pl_sd == nullptr || strncmp(pl_sd->status.name, atcmd_player_name, NAME_LENGTH) != 0) {
		clif_displaymessage(fd, msg_txt(sd, 3)); // Character not found.
		return -1;
	}

	if (!item_db.exists(compensation_item)) {
		clif_displaymessage(fd, "The compensation item is not configured correctly.");
		return -1;
	}

	memset(&msg, 0, sizeof(struct mail_message));

	msg.dest_id = pl_sd->status.char_id;
	safestrncpy(msg.dest_name, pl_sd->status.name, NAME_LENGTH);
	safestrncpy(msg.send_name, "Game Master", NAME_LENGTH);
	safestrncpy(msg.title, "Compensation Package", MAIL_TITLE_LENGTH);
	safestrncpy(msg.body, "Please accept this compensation for the recent inconvenience. Thank you for playing!", MAIL_BODY_LENGTH);

	msg.item[0].nameid = compensation_item;
	msg.item[0].amount = compensation_amount;
	msg.item[0].identify = 1;

	msg.status = MAIL_NEW;
	msg.type = MAIL_INBOX_NORMAL;
	msg.timestamp = time(nullptr);

	intif_Mail_send(0, &msg);

	safesnprintf(atcmd_output, sizeof(atcmd_output), "Compensation package sent to %s.", pl_sd->status.name);
	clif_displaymessage(fd, atcmd_output);

	safesnprintf(atcmd_output, sizeof(atcmd_output), "You have received a compensation package from %s. Please check your mailbox.", sd->status.name);
	clif_displaymessage(pl_sd->fd, atcmd_output);

	return 0;
}
