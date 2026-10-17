extends Node
## Autoload: boots offline demo mode and wires high-level services.
## Networking stays interface-only in Phase 1.

signal offline_ready

var is_offline: bool = true
var network_client: NetworkClientBase


func _ready() -> void:
	network_client = OfflineNetworkClient.new()
	network_client.name = "OfflineNetworkClient"
	add_child(network_client)
	offline_ready.emit()
	print("[PRO-Ragnarok] Phase 1 offline bootstrap complete")


func get_network_client() -> NetworkClientBase:
	return network_client
