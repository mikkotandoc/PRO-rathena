// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "rune.hpp"

#include <algorithm>
#include <cstdlib>
#include <cstring>

#include <common/malloc.hpp>
#include <common/nullpo.hpp>
#include <common/random.hpp>
#include <common/showmsg.hpp>
#include <common/sql.hpp>
#include <common/strlib.hpp>
#include <common/utilities.hpp>

#include "clif.hpp"
#include "itemdb.hpp"
#include "log.hpp"
#include "map.hpp"
#include "pc.hpp"
#include "status.hpp"

using namespace rathena;

RuneBookDatabase runebook_db;
RuneDatabase rune_db;
RuneDecompositionDatabase runedecomposition_db;

static char rune_book_table[32] = "rune_book";
static char rune_set_table[32] = "rune_set";

template <typename keytype, typename datatype>
bool RuneTypesafeYamlDatabase<keytype, datatype>::parseMaterials( const ryml::NodeRef& node, const std::string& key, std::vector<s_rune_material>& out, bool with_chance ){
	if( !this->nodeExists( node, key ) ){
		return true;
	}

	for( const ryml::NodeRef& matNode : node[c4::to_csubstr( key )] ){
		std::string mat_name;
		if( !this->asString( matNode, "Material", mat_name ) ){
			return false;
		}

		std::shared_ptr<item_data> id = item_db.search_aegisname( mat_name.c_str() );
		if( id == nullptr ){
			this->invalidWarning( matNode["Material"], "Unknown material %s, skipping.\n", mat_name.c_str() );
			continue;
		}

		s_rune_material mat = {};
		mat.nameid = id->nameid;
		mat.amount = 1;
		mat.amount_min = 1;
		mat.amount_max = 1;
		mat.chance = 100000;

		if( this->nodeExists( matNode, "Amount" ) ){
			uint16 amount;
			if( !this->asUInt16( matNode, "Amount", amount ) ){
				return false;
			}
			mat.amount = amount;
			mat.amount_min = amount;
			mat.amount_max = amount;
		}
		if( this->nodeExists( matNode, "AmountMin" ) ){
			if( !this->asUInt16( matNode, "AmountMin", mat.amount_min ) ){
				return false;
			}
		}
		if( this->nodeExists( matNode, "AmountMax" ) ){
			if( !this->asUInt16( matNode, "AmountMax", mat.amount_max ) ){
				return false;
			}
		}
		if( with_chance && this->nodeExists( matNode, "Chance" ) ){
			if( !this->asUInt32( matNode, "Chance", mat.chance ) ){
				return false;
			}
		}

		out.push_back( mat );
	}

	return true;
}

// Explicit instantiations used by the three rune DB classes
template bool RuneTypesafeYamlDatabase<uint32, s_runebook>::parseMaterials( const ryml::NodeRef&, const std::string&, std::vector<s_rune_material>&, bool );
template bool RuneTypesafeYamlDatabase<uint32, s_rune_tag>::parseMaterials( const ryml::NodeRef&, const std::string&, std::vector<s_rune_material>&, bool );
template bool RuneTypesafeYamlDatabase<uint32, s_rune_decomposition>::parseMaterials( const ryml::NodeRef&, const std::string&, std::vector<s_rune_material>&, bool );

static int32 rune_count_item( map_session_data& sd, t_itemid nameid ){
	int32 total = 0;
	for( int32 i = 0; i < MAX_INVENTORY; i++ ){
		if( sd.inventory.u.items_inventory[i].nameid == nameid ){
			total += sd.inventory.u.items_inventory[i].amount;
		}
	}
	return total;
}

static bool rune_del_item( map_session_data& sd, t_itemid nameid, int32 amount ){
	for( int32 i = 0; i < MAX_INVENTORY && amount > 0; i++ ){
		struct item* it = &sd.inventory.u.items_inventory[i];
		if( it->nameid != nameid || it->amount <= 0 ){
			continue;
		}
		int32 take = (std::min)( amount, static_cast<int32>( it->amount ) );
		if( pc_delitem( &sd, i, take, 0, 0, LOG_TYPE_OTHER ) != 0 ){
			return false;
		}
		amount -= take;
	}
	return amount <= 0;
}

static bool rune_give_item( map_session_data& sd, t_itemid nameid, int32 amount ){
	struct item it = {};
	it.nameid = nameid;
	it.identify = 1;
	return pc_additem( &sd, &it, amount, LOG_TYPE_OTHER ) == ADDITEM_SUCCESS;
}

static bool rune_take_materials( map_session_data& sd, const std::vector<s_rune_material>& materials ){
	for( const auto& mat : materials ){
		uint16 need = mat.amount ? mat.amount : mat.amount_min;
		if( rune_count_item( sd, mat.nameid ) < need ){
			return false;
		}
	}

	for( const auto& mat : materials ){
		uint16 need = mat.amount ? mat.amount : mat.amount_min;
		if( !rune_del_item( sd, mat.nameid, need ) ){
			return false;
		}
	}

	return true;
}

const std::string RuneBookDatabase::getDefaultLocation(){
	return std::string( db_path ) + "/runebook_db.yml";
}

uint64 RuneBookDatabase::parseBodyNode( const ryml::NodeRef& node ){
	uint32 id;
	if( !this->asUInt32( node, "Id", id ) ){
		return 0;
	}

	std::shared_ptr<s_runebook> entry = this->find( id );
	bool exists = entry != nullptr;

	if( !exists ){
		if( !this->nodesExist( node, { "Name" } ) ){
			return 0;
		}
		entry = std::make_shared<s_runebook>();
		entry->id = id;
	}

	if( this->nodeExists( node, "Name" ) ){
		if( !this->asString( node, "Name", entry->name ) ){
			return 0;
		}
	}

	if( this->nodeExists( node, "Materials" ) ){
		entry->materials.clear();
		if( !this->parseMaterials( node, "Materials", entry->materials, false ) ){
			return 0;
		}
	}else if( !exists ){
		entry->materials.clear();
	}

	if( !exists ){
		this->put( id, entry );
	}

	return 1;
}

const std::string RuneDatabase::getDefaultLocation(){
	return std::string( db_path ) + "/rune_db.yml";
}

std::shared_ptr<s_rune_set> RuneDatabase::findSet( uint32 set_id ){
	for( const auto& tagIt : *this ){
		auto it = tagIt.second->sets.find( set_id );
		if( it != tagIt.second->sets.end() ){
			return it->second;
		}
	}
	return nullptr;
}

uint64 RuneDatabase::parseBodyNode( const ryml::NodeRef& node ){
	uint32 tag_id;
	if( !this->asUInt32( node, "Id", tag_id ) ){
		return 0;
	}

	std::shared_ptr<s_rune_tag> tag = this->find( tag_id );
	bool tag_exists = tag != nullptr;

	if( !tag_exists ){
		tag = std::make_shared<s_rune_tag>();
		tag->id = tag_id;
	}

	if( this->nodeExists( node, "Name" ) ){
		if( !this->asString( node, "Name", tag->name ) ){
			return 0;
		}
	}else if( !tag_exists ){
		tag->name = "Tag_" + std::to_string( tag_id );
	}

	if( !this->nodeExists( node, "Set" ) ){
		if( !tag_exists ){
			this->put( tag_id, tag );
		}
		return 1;
	}

	for( const auto& setNode : node["Set"] ){
		uint32 set_id;
		if( !this->asUInt32( setNode, "Id", set_id ) ){
			return 0;
		}

		std::shared_ptr<s_rune_set> set;
		auto existing = tag->sets.find( set_id );
		bool set_exists = existing != tag->sets.end();

		if( set_exists ){
			set = existing->second;
		}else{
			set = std::make_shared<s_rune_set>();
			set->id = set_id;
			set->tag_id = tag_id;
			memset( set->books, 0, sizeof( set->books ) );
		}

		if( this->nodeExists( setNode, "Name" ) ){
			if( !this->asString( setNode, "Name", set->name ) ){
				return 0;
			}
		}else if( !set_exists ){
			set->name = "Set_" + std::to_string( set_id );
		}

		if( this->nodeExists( setNode, "Books" ) ){
			memset( set->books, 0, sizeof( set->books ) );
			for( const auto& bookNode : setNode["Books"] ){
				uint16 slot = 0;
				if( !this->asUInt16( bookNode, "Slot", slot ) ){
					return 0;
				}
				if( slot >= RUNE_MAX_SLOTS ){
					this->invalidWarning( bookNode["Slot"], "Invalid book slot %u (max %d).\n", slot, RUNE_MAX_SLOTS - 1 );
					continue;
				}

				uint32 book_id = 0;
				if( this->nodeExists( bookNode, "Id" ) ){
					if( !this->asUInt32( bookNode, "Id", book_id ) ){
						return 0;
					}
				}else if( this->nodeExists( bookNode, "Name" ) ){
					std::string book_name;
					if( !this->asString( bookNode, "Name", book_name ) ){
						return 0;
					}
					for( const auto& bookIt : runebook_db ){
						if( bookIt.second->name == book_name ){
							book_id = bookIt.first;
							break;
						}
					}
					if( book_id == 0 ){
						this->invalidWarning( bookNode["Name"], "Unknown rune book %s.\n", book_name.c_str() );
						continue;
					}
				}
				set->books[slot] = book_id;
			}
		}

		if( this->nodeExists( setNode, "Activation" ) ){
			set->activation.clear();
			if( !this->parseMaterials( setNode, "Activation", set->activation, false ) ){
				return 0;
			}
		}

		if( this->nodeExists( setNode, "Scripts" ) ){
			for( auto& old : set->scripts ){
				if( old.script ){
					script_free_code( old.script );
					old.script = nullptr;
				}
			}
			set->scripts.clear();

			for( const auto& scriptNode : setNode["Scripts"] ){
				uint16 amount;
				if( !this->asUInt16( scriptNode, "Amount", amount ) ){
					return 0;
				}
				std::string script;
				if( !this->asString( scriptNode, "Script", script ) ){
					return 0;
				}

				s_rune_set_script entry = {};
				entry.amount = static_cast<uint8>( amount );
				entry.script = parse_script( script.c_str(), this->getCurrentFile().c_str(), this->getLineNumber( scriptNode["Script"] ), SCRIPT_IGNORE_EXTERNAL_BRACKETS );
				set->scripts.push_back( entry );
			}
		}

		if( this->nodeExists( setNode, "Upgrades" ) ){
			set->upgrades.clear();
			for( const auto& upNode : setNode["Upgrades"] ){
				s_rune_upgrade up = {};
				uint16 grade;
				if( !this->asUInt16( upNode, "Grade", grade ) ){
					return 0;
				}
				up.grade = static_cast<uint8>( grade );
				up.chance = 10000;
				up.chance_per_fail = 0;
				if( this->nodeExists( upNode, "Chance" ) && !this->asUInt32( upNode, "Chance", up.chance ) ){
					return 0;
				}
				if( this->nodeExists( upNode, "ChancePerFail" ) && !this->asUInt32( upNode, "ChancePerFail", up.chance_per_fail ) ){
					return 0;
				}
				if( !this->parseMaterials( upNode, "Materials", up.materials, false ) ){
					return 0;
				}
				set->upgrades.push_back( up );
			}
		}

		if( this->nodeExists( setNode, "Rewards" ) ){
			const auto& rewardNode = setNode["Rewards"];
			if( this->nodeExists( rewardNode, "Activation" ) ){
				std::string name;
				if( this->asString( rewardNode, "Activation", name ) ){
					std::shared_ptr<item_data> id = item_db.search_aegisname( name.c_str() );
					if( id ){
						set->reward_activation = id->nameid;
					}
				}
			}
			if( this->nodeExists( rewardNode, "Completion" ) ){
				std::string name;
				if( this->asString( rewardNode, "Completion", name ) ){
					std::shared_ptr<item_data> id = item_db.search_aegisname( name.c_str() );
					if( id ){
						set->reward_completion = id->nameid;
					}
				}
			}
			if( this->nodeExists( rewardNode, "Milestones" ) ){
				for( const auto& mileNode : rewardNode["Milestones"] ){
					uint16 amount;
					std::string name;
					if( !this->asUInt16( mileNode, "Amount", amount ) || !this->asString( mileNode, "Item", name ) ){
						return 0;
					}
					std::shared_ptr<item_data> id = item_db.search_aegisname( name.c_str() );
					if( id ){
						set->rewards[static_cast<uint8>( amount )] = id->nameid;
					}
				}
			}
		}

		tag->sets[set_id] = set;
	}

	if( !tag_exists ){
		this->put( tag_id, tag );
	}

	return 1;
}

const std::string RuneDecompositionDatabase::getDefaultLocation(){
	return std::string( db_path ) + "/runedecomposition_db.yml";
}

uint64 RuneDecompositionDatabase::parseBodyNode( const ryml::NodeRef& node ){
	uint32 id;
	if( !this->asUInt32( node, "Id", id ) ){
		return 0;
	}

	std::shared_ptr<s_rune_decomposition> entry = this->find( id );
	bool exists = entry != nullptr;

	if( !exists ){
		entry = std::make_shared<s_rune_decomposition>();
		entry->id = id;
	}

	if( this->nodeExists( node, "Materials" ) ){
		entry->materials.clear();
		if( !this->parseMaterials( node, "Materials", entry->materials, true ) ){
			return 0;
		}
	}

	if( !exists ){
		this->put( id, entry );
	}

	return 1;
}

void do_init_rune( void ){
	runebook_db.load();
	rune_db.load();
	runedecomposition_db.load();
}

void do_final_rune( void ){
	for( const auto& tagIt : rune_db ){
		for( const auto& setIt : tagIt.second->sets ){
			for( auto& script : setIt.second->scripts ){
				if( script.script ){
					script_free_code( script.script );
					script.script = nullptr;
				}
			}
		}
	}
	runebook_db.clear();
	rune_db.clear();
	runedecomposition_db.clear();
}

void rune_load( map_session_data& sd ){
	sd.rune.books.clear();
	sd.rune.sets.clear();
	sd.rune.loaded = false;

	if( Sql_Query( mmysql_handle, "SELECT `book_id` FROM `%s` WHERE `char_id` = '%u'", rune_book_table, sd.status.char_id ) != SQL_SUCCESS ){
		Sql_ShowDebug( mmysql_handle );
	}else{
		while( Sql_NextRow( mmysql_handle ) == SQL_SUCCESS ){
			char* data;
			Sql_GetData( mmysql_handle, 0, &data, nullptr );
			sd.rune.books.insert( static_cast<uint32>( strtoul( data, nullptr, 10 ) ) );
		}
		Sql_FreeResult( mmysql_handle );
	}

	if( Sql_Query( mmysql_handle, "SELECT `set_id`, `grade`, `fail_count`, `equipped`, `reward_flags` FROM `%s` WHERE `char_id` = '%u'", rune_set_table, sd.status.char_id ) != SQL_SUCCESS ){
		// Older schema without reward_flags — fall back
		if( Sql_Query( mmysql_handle, "SELECT `set_id`, `grade`, `fail_count`, `equipped` FROM `%s` WHERE `char_id` = '%u'", rune_set_table, sd.status.char_id ) != SQL_SUCCESS ){
			Sql_ShowDebug( mmysql_handle );
		}else{
			while( Sql_NextRow( mmysql_handle ) == SQL_SUCCESS ){
				char* data;
				s_pc_rune_set entry = {};
				Sql_GetData( mmysql_handle, 0, &data, nullptr );
				entry.set_id = static_cast<uint32>( strtoul( data, nullptr, 10 ) );
				Sql_GetData( mmysql_handle, 1, &data, nullptr );
				entry.grade = static_cast<uint8>( strtoul( data, nullptr, 10 ) );
				Sql_GetData( mmysql_handle, 2, &data, nullptr );
				entry.fail_count = static_cast<uint16>( strtoul( data, nullptr, 10 ) );
				Sql_GetData( mmysql_handle, 3, &data, nullptr );
				entry.equipped = strtoul( data, nullptr, 10 ) != 0;
				entry.reward_flags = 0;
				sd.rune.sets[entry.set_id] = entry;
			}
			Sql_FreeResult( mmysql_handle );
		}
	}else{
		while( Sql_NextRow( mmysql_handle ) == SQL_SUCCESS ){
			char* data;
			s_pc_rune_set entry = {};
			Sql_GetData( mmysql_handle, 0, &data, nullptr );
			entry.set_id = static_cast<uint32>( strtoul( data, nullptr, 10 ) );
			Sql_GetData( mmysql_handle, 1, &data, nullptr );
			entry.grade = static_cast<uint8>( strtoul( data, nullptr, 10 ) );
			Sql_GetData( mmysql_handle, 2, &data, nullptr );
			entry.fail_count = static_cast<uint16>( strtoul( data, nullptr, 10 ) );
			Sql_GetData( mmysql_handle, 3, &data, nullptr );
			entry.equipped = strtoul( data, nullptr, 10 ) != 0;
			Sql_GetData( mmysql_handle, 4, &data, nullptr );
			entry.reward_flags = static_cast<uint32>( strtoul( data, nullptr, 10 ) );
			sd.rune.sets[entry.set_id] = entry;
		}
		Sql_FreeResult( mmysql_handle );
	}

	sd.rune.loaded = true;
}

static bool rune_reward_claimed( const s_pc_rune_set& state, uint8 key ){
	return ( state.reward_flags & ( 1u << key ) ) != 0;
}

static void rune_reward_mark( s_pc_rune_set& state, uint8 key ){
	state.reward_flags |= ( 1u << key );
}

void rune_grant_set_rewards( map_session_data& sd, const s_rune_set& set, uint8 pages, bool include_activation ){
	auto it = sd.rune.sets.find( set.id );
	if( it == sd.rune.sets.end() ){
		return;
	}
	s_pc_rune_set& state = it->second;

	if( include_activation && set.reward_activation && !rune_reward_claimed( state, 0 ) ){
		if( rune_give_item( sd, set.reward_activation, 1 ) ){
			rune_reward_mark( state, 0 );
		}
	}

	for( const auto& reward : set.rewards ){
		// Milestone bits use page-count keys 2..6 (0 = activation, 7 = completion)
		if( pages < reward.first || reward.first < 2 || reward.first > 6 ){
			continue;
		}
		if( rune_reward_claimed( state, reward.first ) ){
			continue;
		}
		if( rune_give_item( sd, reward.second, 1 ) ){
			rune_reward_mark( state, reward.first );
		}
	}

	uint8 total_slots = 0;
	for( int32 i = 0; i < RUNE_MAX_SLOTS; i++ ){
		if( set.books[i] != 0 ){
			total_slots++;
		}
	}
	if( set.reward_completion && pages >= total_slots && total_slots > 0 && !rune_reward_claimed( state, 7 ) ){
		if( rune_give_item( sd, set.reward_completion, 1 ) ){
			rune_reward_mark( state, 7 );
		}
	}
}

void rune_save( map_session_data& sd ){
	if( !sd.rune.loaded ){
		return;
	}

	if( Sql_Query( mmysql_handle, "DELETE FROM `%s` WHERE `char_id` = '%u'", rune_book_table, sd.status.char_id ) != SQL_SUCCESS ){
		Sql_ShowDebug( mmysql_handle );
	}
	for( uint32 book_id : sd.rune.books ){
		if( Sql_Query( mmysql_handle, "INSERT INTO `%s` (`char_id`, `book_id`) VALUES ('%u', '%u')", rune_book_table, sd.status.char_id, book_id ) != SQL_SUCCESS ){
			Sql_ShowDebug( mmysql_handle );
		}
	}

	if( Sql_Query( mmysql_handle, "DELETE FROM `%s` WHERE `char_id` = '%u'", rune_set_table, sd.status.char_id ) != SQL_SUCCESS ){
		Sql_ShowDebug( mmysql_handle );
	}
	for( const auto& it : sd.rune.sets ){
		const s_pc_rune_set& entry = it.second;
		if( Sql_Query( mmysql_handle,
			"INSERT INTO `%s` (`char_id`, `set_id`, `grade`, `fail_count`, `equipped`, `reward_flags`) VALUES ('%u', '%u', '%u', '%u', '%u', '%u')",
			rune_set_table, sd.status.char_id, entry.set_id, entry.grade, entry.fail_count, entry.equipped ? 1 : 0, entry.reward_flags ) != SQL_SUCCESS ){
			Sql_ShowDebug( mmysql_handle );
		}
	}
}

bool rune_has_book( const map_session_data& sd, uint32 book_id ){
	return sd.rune.books.find( book_id ) != sd.rune.books.end();
}

uint8 rune_set_book_count( const map_session_data& sd, const s_rune_set& set ){
	uint8 count = 0;
	for( int32 i = 0; i < RUNE_MAX_SLOTS; i++ ){
		if( set.books[i] != 0 && rune_has_book( sd, set.books[i] ) ){
			count++;
		}
	}
	return count;
}

uint8 rune_get_grade( const map_session_data& sd ){
	for( const auto& it : sd.rune.sets ){
		if( it.second.equipped ){
			return it.second.grade;
		}
	}
	return 0;
}

uint32 rune_get_equipped_set( const map_session_data& sd ){
	for( const auto& it : sd.rune.sets ){
		if( it.second.equipped ){
			return it.second.set_id;
		}
	}
	return 0;
}

bool rune_activate_book( map_session_data& sd, uint32 book_id ){
	std::shared_ptr<s_runebook> book = runebook_db.find( book_id );
	if( book == nullptr ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Invalid rune page.", false, SELF );
		return false;
	}
	if( rune_has_book( sd, book_id ) ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "This rune page is already activated.", false, SELF );
		return false;
	}
	if( !rune_take_materials( sd, book->materials ) ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "You lack the materials to activate this rune page.", false, SELF );
		return false;
	}

	sd.rune.books.insert( book_id );

	// Grant newly unlocked milestone rewards for any already-activated sets that use this page
	for( const auto& tagIt : rune_db ){
		for( const auto& setIt : tagIt.second->sets ){
			const s_rune_set& set = *setIt.second;
			bool uses_book = false;
			for( int32 i = 0; i < RUNE_MAX_SLOTS; i++ ){
				if( set.books[i] == book_id ){
					uses_book = true;
					break;
				}
			}
			if( !uses_book || sd.rune.sets.find( set.id ) == sd.rune.sets.end() ){
				continue;
			}
			rune_grant_set_rewards( sd, set, rune_set_book_count( sd, set ), false );
		}
	}

	rune_save( sd );
	status_calc_pc( &sd, SCO_FORCE );
	clif_messagecolor( &sd, color_table[COLOR_CYAN], "Rune page activated.", false, SELF );
	return true;
}

bool rune_activate_set( map_session_data& sd, uint32 set_id ){
	std::shared_ptr<s_rune_set> set = rune_db.findSet( set_id );
	if( set == nullptr ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Invalid rune tablet set.", false, SELF );
		return false;
	}
	if( sd.rune.sets.find( set_id ) != sd.rune.sets.end() ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "This rune tablet is already activated.", false, SELF );
		return false;
	}

	uint8 pages = rune_set_book_count( sd, *set );
	if( pages < 1 ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Activate at least one matching rune page first.", false, SELF );
		return false;
	}
	if( !rune_take_materials( sd, set->activation ) ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "You lack the materials to activate this tablet.", false, SELF );
		return false;
	}

	s_pc_rune_set entry = {};
	entry.set_id = set_id;
	entry.grade = 0;
	entry.fail_count = 0;
	entry.equipped = false;
	entry.reward_flags = 0;
	sd.rune.sets[set_id] = entry;

	rune_grant_set_rewards( sd, *set, pages, true );

	rune_save( sd );
	status_calc_pc( &sd, SCO_FORCE );
	clif_messagecolor( &sd, color_table[COLOR_CYAN], "Rune tablet activated.", false, SELF );
	return true;
}

bool rune_equip_set( map_session_data& sd, uint32 set_id ){
	auto it = sd.rune.sets.find( set_id );
	if( it == sd.rune.sets.end() ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Activate this tablet before equipping it.", false, SELF );
		return false;
	}

	std::shared_ptr<s_rune_set> set = rune_db.findSet( set_id );
	if( set == nullptr ){
		return false;
	}
	if( rune_set_book_count( sd, *set ) < 2 ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "At least 2 rune pages are required for tablet effects.", false, SELF );
		return false;
	}

	for( auto& entry : sd.rune.sets ){
		entry.second.equipped = ( entry.first == set_id );
	}

	rune_save( sd );
	status_calc_pc( &sd, SCO_FORCE );
	clif_messagecolor( &sd, color_table[COLOR_CYAN], "Rune tablet equipped.", false, SELF );
	return true;
}

bool rune_unequip_set( map_session_data& sd ){
	bool changed = false;
	for( auto& entry : sd.rune.sets ){
		if( entry.second.equipped ){
			entry.second.equipped = false;
			changed = true;
		}
	}
	if( !changed ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "No rune tablet is currently equipped.", false, SELF );
		return false;
	}
	rune_save( sd );
	status_calc_pc( &sd, SCO_FORCE );
	clif_messagecolor( &sd, color_table[COLOR_CYAN], "Rune tablet unequipped.", false, SELF );
	return true;
}

bool rune_upgrade_set( map_session_data& sd, uint32 set_id ){
	auto it = sd.rune.sets.find( set_id );
	if( it == sd.rune.sets.end() ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Activate this tablet before upgrading it.", false, SELF );
		return false;
	}

	s_pc_rune_set& state = it->second;
	if( state.grade >= RUNE_MAX_GRADE ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "This tablet is already at maximum grade.", false, SELF );
		return false;
	}

	std::shared_ptr<s_rune_set> set = rune_db.findSet( set_id );
	if( set == nullptr ){
		return false;
	}

	const s_rune_upgrade* up = nullptr;
	for( const auto& entry : set->upgrades ){
		if( entry.grade == state.grade ){
			up = &entry;
			break;
		}
	}
	if( up == nullptr ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "No upgrade data for this grade.", false, SELF );
		return false;
	}
	if( !rune_take_materials( sd, up->materials ) ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "You lack the materials to upgrade this tablet.", false, SELF );
		return false;
	}

	// Client GradeTable uses 10000 = 100%
	uint32 chance = up->chance + ( static_cast<uint32>( state.fail_count ) * up->chance_per_fail );
	if( chance > 10000 ){
		chance = 10000;
	}

	if( static_cast<uint32>( rnd() % 10000 ) < chance ){
		state.grade++;
		state.fail_count = 0;
		clif_messagecolor( &sd, color_table[COLOR_CYAN], "Rune tablet upgrade succeeded.", false, SELF );
	}else{
		state.fail_count++;
		clif_messagecolor( &sd, color_table[COLOR_RED], "Rune tablet upgrade failed. Success rate increased.", false, SELF );
	}

	rune_save( sd );
	status_calc_pc( &sd, SCO_FORCE );
	return true;
}

bool rune_decompose( map_session_data& sd, uint16 index, uint8 type ){
	if( index >= MAX_INVENTORY ){
		return false;
	}
	struct item* it = &sd.inventory.u.items_inventory[index];
	if( it->nameid == 0 || sd.inventory_data[index] == nullptr ){
		return false;
	}

	uint32 pool_id = ( type == 1 ) ? sd.inventory_data[index]->rune_decomp_type1 : sd.inventory_data[index]->rune_decomp_type2;
	if( pool_id == 0 ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "This item cannot be decomposed.", false, SELF );
		return false;
	}

	std::shared_ptr<s_rune_decomposition> pool = runedecomposition_db.find( pool_id );
	if( pool == nullptr ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Decomposition table missing.", false, SELF );
		return false;
	}

	// Matches official itemDecomItemNum_tbl = { 1, 30 }
	uint16 amount = ( type == 1 ) ? 1 : 30;
	if( it->amount < amount ){
		clif_messagecolor( &sd, color_table[COLOR_RED], "Not enough cards to decompose.", false, SELF );
		return false;
	}

	if( pc_delitem( &sd, index, amount, 0, 0, LOG_TYPE_OTHER ) != 0 ){
		return false;
	}

	for( const auto& mat : pool->materials ){
		if( static_cast<uint32>( rnd() % 100000 ) >= mat.chance ){
			continue;
		}
		uint16 give = mat.amount_min;
		if( mat.amount_max > mat.amount_min ){
			give = static_cast<uint16>( mat.amount_min + rnd() % ( mat.amount_max - mat.amount_min + 1 ) );
		}
		if( give > 0 ){
			rune_give_item( sd, mat.nameid, give );
		}
	}

	clif_messagecolor( &sd, color_table[COLOR_CYAN], "Card decomposed.", false, SELF );
	return true;
}

void rune_apply_bonuses( map_session_data& sd ){
	uint32 set_id = rune_get_equipped_set( sd );
	if( set_id == 0 ){
		return;
	}

	std::shared_ptr<s_rune_set> set = rune_db.findSet( set_id );
	if( set == nullptr ){
		return;
	}

	uint8 pages = rune_set_book_count( sd, *set );
	if( pages < 2 ){
		return;
	}

	for( const auto& entry : set->scripts ){
		if( pages >= entry.amount && entry.script != nullptr ){
			run_script( entry.script, 0, sd.id, 0 );
		}
	}
}
