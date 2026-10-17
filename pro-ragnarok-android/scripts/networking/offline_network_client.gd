class_name OfflineNetworkClient
extends NetworkClientBase
## Phase 1 stub: always offline. Satisfies the networking interface boundary.


func get_connection_state() -> int:
	return ConnectionState.DISCONNECTED


func is_connected_to_server() -> bool:
	return false


func connect_to_server(_host: String, _port: int) -> Error:
	# Explicit refusal — offline prototype must not pretend to speak RO protocol.
	return ERR_UNAVAILABLE


func disconnect_from_server() -> void:
	connection_state_changed.emit(ConnectionState.DISCONNECTED)
	disconnected.emit("offline_mode")


func send_raw(_payload: PackedByteArray) -> Error:
	return ERR_UNAVAILABLE


func poll() -> void:
	pass
