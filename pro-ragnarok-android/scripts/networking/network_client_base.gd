class_name NetworkClientBase
extends Node
## Interface-only contract for a future native TCP client to rAthena.
## Phase 1: no speculative RO packets, no WebSocket/browser networking.
## PACKETVER will be derived later from real rAthena source — not invented here.

signal connection_state_changed(state: int)
signal disconnected(reason: String)

enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	AUTHENTICATED,
}


func get_connection_state() -> int:
	return ConnectionState.DISCONNECTED


func is_connected_to_server() -> bool:
	return false


## Future: connect via native TCP. Host/port only — no packet layout assumed.
func connect_to_server(_host: String, _port: int) -> Error:
	push_warning("NetworkClientBase.connect_to_server: not implemented (Phase 1 offline)")
	return ERR_UNAVAILABLE


func disconnect_from_server() -> void:
	pass


## Future: send raw bytes once PACKETVER and structs are taken from rAthena.
func send_raw(_payload: PackedByteArray) -> Error:
	push_warning("NetworkClientBase.send_raw: not implemented (Phase 1 offline)")
	return ERR_UNAVAILABLE


## Future: receive raw bytes from the login/char/map servers.
func poll() -> void:
	pass
