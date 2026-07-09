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
 * Opens the Rune Tablet / Rune System UI for GM testing.
 * Usage: @runeui {<ui type>}
 *        @runetablet {<ui type>}
 *
 * Optional <ui type> overrides the default OUT_UI_RUNE (11) so GMs can
 * probe which ZC_UI_OPEN type the client expects.
 */
ACMD_FUNC(runeui)
{
	nullpo_retr(-1, sd);

#if PACKETVER < 20230802
	clif_displaymessage(fd, "This command requires packet version 2023-08-02 or newer.");
	return -1;
#else
	int32 ui_type = OUT_UI_RUNE;

	if (message != nullptr && *message) {
		if (sscanf(message, "%11d", &ui_type) < 1 || ui_type < 0 || ui_type > 127) {
			clif_displaymessage(fd, "Usage: @runeui {<ui type>}");
			return -1;
		}
	}

	clif_ui_open(*sd, static_cast<enum out_ui_type>(ui_type), 0);
	return 0;
#endif
}
