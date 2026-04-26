extends Control

var client: Node = null
@onready var host: LineEdit = get_node_or_null("VBoxContainer/Connect/Host") as LineEdit
@onready var room: LineEdit = get_node_or_null("VBoxContainer/Connect/RoomSecret") as LineEdit
@onready var mesh: CheckBox = get_node_or_null("VBoxContainer/Connect/Mesh") as CheckBox

func _ready() -> void:
	client = get_node_or_null("Client")
	if client:
		client.lobby_joined.connect(_lobby_joined)
		client.lobby_sealed.connect(_lobby_sealed)
		client.connected.connect(_connected)
		client.disconnected.connect(_disconnected)
	else:
		push_warning("demo/client_ui.gd: 'Client' node missing; client signals will not be connected.")

	multiplayer.connected_to_server.connect(_mp_server_connected)
	multiplayer.connection_failed.connect(_mp_server_disconnect)
	multiplayer.server_disconnected.connect(_mp_server_disconnect)
	multiplayer.peer_connected.connect(_mp_peer_connected)
	multiplayer.peer_disconnected.connect(_mp_peer_disconnected)


@rpc("any_peer", "call_local")
func ping(argument: float) -> void:
	_log("[Multiplayer] Ping from peer %d: arg: %f" % [multiplayer.get_remote_sender_id(), argument])


func _mp_server_connected() -> void:
	_log("[Multiplayer] Server connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect() -> void:
	_log("[Multiplayer] Server disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int) -> void:
	_log("[Multiplayer] Peer %d connected" % id)


func _mp_peer_disconnected(id: int) -> void:
	_log("[Multiplayer] Peer %d disconnected" % id)


func _connected(id: int, use_mesh: bool) -> void:
	_log("[Signaling] Server connected with ID: %d. Mesh: %s" % [id, use_mesh])


func _disconnected() -> void:
	_log("[Signaling] Server disconnected: %d - %s" % [client.code, client.reason])


func _lobby_joined(lobby: String) -> void:
	_log("[Signaling] Joined lobby %s" % lobby)


func _lobby_sealed() -> void:
	_log("[Signaling] Lobby has been sealed")


func _log(msg: String) -> void:
	print(msg)
	var text_edit = get_node_or_null("VBoxContainer/TextEdit")
	if text_edit:
		if text_edit.has_method("append"):
			text_edit.append(str(msg) + "\n")
		elif text_edit.has_method("set_text") or text_edit.has_meta("text") or ("text" in text_edit):
			text_edit.text = str(text_edit.text) + str(msg) + "\n"
		else:
			push_warning("demo/client_ui.gd: TextEdit node exists but doesn't expose text/append")
	else:
		pass


func _on_peers_pressed() -> void:
	_log(str(multiplayer.get_peers()))


func _on_ping_pressed() -> void:
	ping.rpc(randf())


func _on_seal_pressed() -> void:
	client.seal_lobby()


func _on_start_pressed() -> void:
	if client == null:
		push_warning("demo/client_ui.gd: client node is null; cannot start")
		return

	if host == null or room == null:
		push_warning("demo/client_ui.gd: Host or Room LineEdit missing. Check scene paths: VBoxContainer/Connect/Host and VBoxContainer/Connect/RoomSecret")
		return

	var use_mesh := false
	if mesh != null:
		use_mesh = mesh.button_pressed

	client.start(host.text, room.text, use_mesh)


func _on_stop_pressed() -> void:
	client.stop()
