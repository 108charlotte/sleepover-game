extends CharacterBody2D

const GRID_SIZE = 128  # Size of each grid cell in pixels
const MOVE_SPEED = 0  # Seconds to tween between cells (lower = faster)

@export var player_id := 1:
	set(id):
		player_id = id
		set_multiplayer_authority(id)

var _is_moving := false
var _target_position := Vector2.ZERO

func _ready() -> void:
	player_id = int(name)
	# Snap to grid on start
	position = position.snapped(Vector2(GRID_SIZE, GRID_SIZE))
	_target_position = position
	print("My peer ID: %s | This player's ID: %s | Am I authority: %s" % [
		multiplayer.get_unique_id(),
		player_id,
		is_multiplayer_authority()
	])

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if _is_moving:
		return

	var direction := Vector2.ZERO

	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_up"):
		direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		direction = Vector2.DOWN

	if direction != Vector2.ZERO:
		_move(direction)

func _move(direction: Vector2) -> void:
	var next_position = _target_position + direction * GRID_SIZE

	# Optional: collision check before moving
	var space = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, next_position)
	query.exclude = [self]
	var result = space.intersect_ray(query)
	if result:
		return  # Blocked, don't move

	_target_position = next_position
	_is_moving = true

	var tween = create_tween()
	tween.tween_property(self, "position", _target_position, MOVE_SPEED)
	tween.tween_callback(func(): _is_moving = false)
