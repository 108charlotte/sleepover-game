extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://multiplayer_player.tscn")

var _players_spawn_node

func become_host(): 
	print("Starting host")
	
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	_add_player_to_game(1) # host always has id of 1

func join_room(): 
	print("Join room pressed")
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	_remove_single_player()

func _add_player_to_game(id: int): 
	if not multiplayer.is_server():
		return
	print("_add_player_to_game called with id: %s, is_server: %s" % [id, multiplayer.is_server()])
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	_remove_single_player()

func _del_player(id: int): 
	print("Player %s left the game" % id)

func _remove_single_player():
	print("Remove single Player")
	var player_to_remove = get_tree().get_current_scene().get_node_or_null("Player")
	if player_to_remove:
		player_to_remove.queue_free()
