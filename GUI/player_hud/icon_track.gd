extends Sprite2D


@export var hud_signal_name := ''

@onready var ap: AnimationPlayer = $ap



func _ready() -> void:
	PlayerHud[hud_signal_name].connect(func(state: bool) -> void:
		ap.play(&'open' if state else &'RESET')
	)
