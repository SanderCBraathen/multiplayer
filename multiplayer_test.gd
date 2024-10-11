extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@onready var ip_address_input: LineEdit = $LineEdit  # Assuming you've added a LineEdit node named IPAddressInput

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_host_pressed() -> void:
	var error = peer.create_server(135)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
	else:
		print("Failed to create server: ", error)

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _on_join_pressed() -> void:
	var ip = ip_address_input.text.strip_edges()
	if ip.is_empty():
		ip = "localhost"  # Default to localhost if no IP is entered
	
	var error = peer.create_client(ip, 135)
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		print("Failed to create client: ", error)

func _on_connected_to_server():
	_add_player(multiplayer.get_unique_id())
