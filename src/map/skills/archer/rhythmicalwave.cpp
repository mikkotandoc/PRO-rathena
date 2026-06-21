// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "rhythmicalwave.hpp"

#include <config/core.hpp>

#include "map/battle.hpp"
#include "map/clif.hpp"
#include "map/pc.hpp"
#include "map/status.hpp"

SkillRhythmicalWave::SkillRhythmicalWave() : SkillImplRecursiveDamageSplash(TR_RHYTHMICAL_WAVE) {
}

void SkillRhythmicalWave::splashSearch(block_list* src, block_list* target, uint16 skill_lv, t_tick tick, int32 flag) const {
	map_session_data* sd = BL_CAST(BL_PC, src);

	clif_skill_nodamage(src, *target, getSkillId(), skill_lv);

	SkillImplRecursiveDamageSplash::splashSearch(src, target, skill_lv, tick, flag);

	// Consume here since magic attacks reset arrow_atk before ammo is deducted.
	battle_consume_ammo(sd, getSkillId(), skill_lv);
}

void SkillRhythmicalWave::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& skillratio, int32 mflag) const {
	const map_session_data* sd = BL_CAST(BL_PC, src);
	const status_change* sc = status_get_sc(src);
	const status_data* sstatus = status_get_status_data(*src);

	skillratio += -100 + 250 + 3650 * skill_lv;
	skillratio += pc_checkskill(sd, TR_STAGE_MANNER) * 25;
	skillratio += 5 * sstatus->spl;

	if (sc != nullptr && sc->hasSCE(SC_MYSTIC_SYMPHONY))
		skillratio += 200 + 1000 * skill_lv;

	RE_LVL_DMOD(100);
}

void SkillRhythmicalWave::modifyElement(const Damage& dmg, const block_list& src, const block_list& target, uint16 skill_lv, int32& element, int32 flag) const {
	const map_session_data* sd = BL_CAST(BL_PC, &src);

	if (sd != nullptr)
		element = sd->bonus.arrow_ele;
}
