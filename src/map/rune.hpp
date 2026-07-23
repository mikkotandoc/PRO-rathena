// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#ifndef RUNE_HPP
#define RUNE_HPP

#include <memory>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include <common/cbasetypes.hpp>
#include <common/database.hpp>
#include <common/mmo.hpp>

#include "script.hpp"

class map_session_data;

/// Maximum upgrade grade for a rune tablet set (+1 .. +15 stored as 1..15; DB grades 0..14)
#define RUNE_MAX_GRADE 15
/// Maximum rune page slots per tablet set
#define RUNE_MAX_SLOTS 6

struct s_rune_material {
	t_itemid nameid;
	uint16 amount;
	uint16 amount_min;
	uint16 amount_max;
	uint32 chance; // 100000 = 100%
};

struct s_runebook {
	uint32 id;
	std::string name;
	std::vector<s_rune_material> materials;
};

struct s_rune_set_script {
	uint8 amount; // number of activated pages required
	struct script_code *script;
};

struct s_rune_upgrade {
	uint8 grade; // 0..14 => attempting +1..+15
	uint32 chance;
	uint32 chance_per_fail;
	std::vector<s_rune_material> materials;
};

struct s_rune_set {
	uint32 id;
	std::string name;
	uint32 tag_id;
	uint32 books[RUNE_MAX_SLOTS]; // 0 = empty slot
	std::vector<s_rune_material> activation;
	std::vector<s_rune_set_script> scripts;
	std::vector<s_rune_upgrade> upgrades;
	/// Milestone rewards: page_count -> item id (0 = activation reward key used as special)
	std::unordered_map<uint8, t_itemid> rewards;
	t_itemid reward_activation = 0;
	t_itemid reward_completion = 0;
};

struct s_rune_tag {
	uint32 id;
	std::string name;
	std::unordered_map<uint32, std::shared_ptr<s_rune_set>> sets;
};

struct s_rune_decomposition {
	uint32 id;
	std::vector<s_rune_material> materials;
};

/// Shared YAML helpers for rune DBs (needs protected YamlDatabase accessors)
template <typename keytype, typename datatype>
class RuneTypesafeYamlDatabase : public TypesafeYamlDatabase<keytype, datatype> {
protected:
	RuneTypesafeYamlDatabase( const std::string& type_, uint16 version_ ) : TypesafeYamlDatabase<keytype, datatype>( type_, version_ ) {}

	bool parseMaterials( const ryml::NodeRef& node, const std::string& key, std::vector<s_rune_material>& out, bool with_chance );
};

class RuneBookDatabase : public RuneTypesafeYamlDatabase<uint32, s_runebook> {
public:
	RuneBookDatabase() : RuneTypesafeYamlDatabase( "RUNEBOOK_DB", 1 ) {}

	const std::string getDefaultLocation() override;
	uint64 parseBodyNode( const ryml::NodeRef& node ) override;
};

class RuneDatabase : public RuneTypesafeYamlDatabase<uint32, s_rune_tag> {
public:
	RuneDatabase() : RuneTypesafeYamlDatabase( "RUNE_DB", 1 ) {}

	const std::string getDefaultLocation() override;
	uint64 parseBodyNode( const ryml::NodeRef& node ) override;
	std::shared_ptr<s_rune_set> findSet( uint32 set_id );
};

class RuneDecompositionDatabase : public RuneTypesafeYamlDatabase<uint32, s_rune_decomposition> {
public:
	RuneDecompositionDatabase() : RuneTypesafeYamlDatabase( "RUNEDECOMPOSITION_DB", 1 ) {}

	const std::string getDefaultLocation() override;
	uint64 parseBodyNode( const ryml::NodeRef& node ) override;
};

extern RuneBookDatabase runebook_db;
extern RuneDatabase rune_db;
extern RuneDecompositionDatabase runedecomposition_db;

struct s_pc_rune_set {
	uint32 set_id;
	uint8 grade;
	uint16 fail_count;
	bool equipped;
	/// bit0=activation, bit1=completion, bitN=milestone for N pages (2..6)
	uint32 reward_flags;
};

struct s_pc_rune {
	std::unordered_set<uint32> books;
	std::unordered_map<uint32, s_pc_rune_set> sets;
	bool loaded = false;
};

void do_init_rune( void );
void do_final_rune( void );

void rune_load( map_session_data& sd );
void rune_save( map_session_data& sd );

bool rune_has_book( const map_session_data& sd, uint32 book_id );
uint8 rune_set_book_count( const map_session_data& sd, const s_rune_set& set );
uint8 rune_get_grade( const map_session_data& sd );
uint32 rune_get_equipped_set( const map_session_data& sd );

bool rune_activate_book( map_session_data& sd, uint32 book_id );
bool rune_activate_set( map_session_data& sd, uint32 set_id );
bool rune_equip_set( map_session_data& sd, uint32 set_id );
bool rune_unequip_set( map_session_data& sd );
bool rune_upgrade_set( map_session_data& sd, uint32 set_id );
bool rune_decompose( map_session_data& sd, uint16 index, uint8 type );
void rune_grant_set_rewards( map_session_data& sd, const s_rune_set& set, uint8 pages, bool include_activation );

void rune_apply_bonuses( map_session_data& sd );

#endif /* RUNE_HPP */
