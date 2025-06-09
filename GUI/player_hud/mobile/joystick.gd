extends Control


signal on_touch_changed(vector: Vector2, strength: float)
signal on_touch_end

const MIN_DRAG_PIXELS: int = 25

@onready var joystick_zone: TextureButton = $joystick_zone
@onready var joystick: Panel = $joystick_main/joystick
@onready var thumb: Panel = joystick.get_node('thumb')



var _is_touching_zone := false

var _start_pos := Vector2.ZERO
var _tween: Tween = null


func _ready() -> void:
	joystick_zone.button_down.connect(func() -> void:
		_is_touching_zone = true
		set_process_input(true)
	)
	
	joystick_zone.button_up.connect(func() -> void:
		on_touch_end.emit()
		_is_touching_zone = false
		set_process_input(false)
		
		_create_tween()
		_tween.tween_property(joystick, 'position', Vector2.ZERO, 0.25)
		_tween.play()
		
		thumb.position = _get_thumb_centered_position()
		thumb.rotation = 0.0
		
		PlayerManager.on_joystick_touch_end.emit()
		_start_pos = Vector2.ZERO
	)




func _get_thumb_centered_position() -> Vector2:
	return (joystick.size / 2.0) - (thumb.size / 2.0)


func _create_tween() -> void:
	if not _tween or not _tween.is_valid():
		_tween = create_tween().set_parallel()
		_tween = _tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		#_tween.finished.connect(_kill_tween)
	_tween.stop()

func _kill_tween() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null



func _input(event: InputEvent) -> void:
	if _is_touching_zone and (event is InputEventScreenDrag):
		var mouse_position: Vector2 = get_global_mouse_position()
		
		if _start_pos == Vector2.ZERO:
			_start_pos = mouse_position
			var final_position := mouse_position - (joystick.size / 2.0)
			_create_tween()
			_tween.tween_property(joystick, 'global_position', final_position, 0.25)
			_tween.play()
		
		
		var dir: Vector2 = (mouse_position - _start_pos)
		var length_max: float = (joystick.size.x / 2.0)
		var length: float = minf(dir.length(), (joystick.size.x / 2.0))
		
		thumb.pivot_offset = (thumb.size / 2.0) - Vector2(length, 0)
		thumb.position = _get_thumb_centered_position() + Vector2(length, 0)
		thumb.rotation = dir.angle()
		
		dir = dir.normalized()
		on_touch_changed.emit(dir, length / float(length_max))
		PlayerManager.on_joystick_touch.emit(dir, length / float(length_max))
