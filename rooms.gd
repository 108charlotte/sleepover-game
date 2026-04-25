extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func become_host(): 
	print("Become host pressed")
	MultiplayerManager.become_host()
	%MultiplayerHUD.hide()
	%gridworld.show()

func join_room(): 
	print("Join room pressed")
	MultiplayerManager.join_room()
	%MultiplayerHUD.hide()
	%gridworld.show()
