extends Sprite3D

var _base_y: float
var _time: float = 0.0
const FLOAT_SPEED: float = 2.5
const FLOAT_AMOUNT: float = 0.15


func _ready():
	_base_y = position.y


func _process(delta: float):
	_time += delta
	position.y = _base_y + sin(_time * FLOAT_SPEED) * FLOAT_AMOUNT
