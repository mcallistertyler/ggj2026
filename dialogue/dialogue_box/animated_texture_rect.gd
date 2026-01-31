@tool
class_name AnimatedTextureRect extends TextureRect
@export var sprites : SpriteFrames
@export var current_animation := "default"
@export var frame_index := 0
@export var speed_scale := 1.0 # (float, 0.0, 1000000, 0.001)
@export var auto_play := false
@export var playing := false
var refresh_rate = 1.0
var fps = 60.0
var frame_delta = 0

func set_sprite(_sprites):
	self.sprites = _sprites
	self.stop()
	self.play(current_animation)

func _ready():
	if sprites != null:
		fps = sprites.get_animation_speed(current_animation)
		if auto_play:
			play()
		

func _process(delta):
	if sprites == null or playing == false:
		return
	get_animation_data(current_animation)
	frame_delta += speed_scale * delta
	if frame_delta >= refresh_rate/fps:
		texture = get_next_frame()
		frame_delta = 0
		
func get_next_frame():
	frame_index += 1
	var frame_count = sprites.get_frame_count(current_animation)
	if frame_index >= frame_count:
		frame_index = 0
		if not sprites.get_animation_loop(current_animation):
			playing = false
	get_animation_data(current_animation)
	return sprites.get_frame_texture(current_animation, frame_index)
	
func play(animation_name: String = current_animation):
	frame_index = 0
	frame_delta = 0
	current_animation = animation_name
	get_animation_data(current_animation)
	playing = true
	
func get_animation_data(animation):
	fps = sprites.get_animation_speed(current_animation)
	
func resume():
	playing = true
	
func pause():
	playing = false
	
func stop():
	frame_index = 0
	playing = false
