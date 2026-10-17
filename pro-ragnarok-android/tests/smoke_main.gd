extends SceneTree
## Boots main.tscn briefly and quits — smoke check for script errors.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("smoke: failed to load main.tscn")
		quit(1)
		return
	var main := packed.instantiate()
	root.add_child(main)
	for i in range(30):
		await process_frame
	print("[smoke] main scene ran OK")
	quit(0)
