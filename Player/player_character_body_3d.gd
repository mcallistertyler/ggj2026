extends CharacterBody3D
class_name PlayerCharacterBody3D

@export var speed : float = 5.0
@export var gravity : float = 9.8
@export var animated_sprite : AnimatedSprite3D
@export var animation_player : AnimationPlayer
@export var interaction_symbol : Sprite3D

enum PlayerStates { IDLE, WALK }

var movement_disabled : bool = false

func show_interact() -> void:
	if !interaction_symbol.visible:
		interaction_symbol.visible = true
		
func hide_interact() -> void:
	if interaction_symbol.visible:
		interaction_symbol.visible = false 

func _on_player_movement(is_enabled: bool) -> void:
	movement_disabled = not is_enabled

func _ready() -> void:
	PlayerManager.player_movement.connect(_on_player_movement)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement_disabled:
		input_dir = Vector2.ZERO
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	self.move_and_slide()
