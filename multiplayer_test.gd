# multiplayer_test.gd
extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var projectile_scene: PackedScene
@onready var ip_address_input: LineEdit = $LineEdit

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_host_pressed() -> void:
	var error = peer.create_server(135)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player()
	else:
		print("Failed to create server: ", error)

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _remove_player(id):
	if has_node(str(id)):
		var player = get_node(str(id))
		player.queue_free()

func _on_join_pressed() -> void:
	var ip = ip_address_input.text.strip_edges()
	if ip.is_empty():
		ip = "localhost"
	
	var error = peer.create_client(ip, 135)
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		print("Failed to create client: ", error)

func _on_connected_to_server():
	_add_player(multiplayer.get_unique_id())

func _on_peer_disconnected(id):
	_remove_player(id)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_handle_exit()

func _handle_exit():
	if multiplayer.is_server():
		for id in multiplayer.get_peers():
			_remove_player(id)
	multiplayer.multiplayer_peer = null
	get_tree().quit()

func get_projectile_scene() -> PackedScene:
	return projectile_scene
