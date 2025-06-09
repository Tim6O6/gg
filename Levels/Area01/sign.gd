extends Node2D



@export var sign_text := ''

@onready var label: Label = $sprite/label
@onready var interact_area: Area2D = $interact_area



func _ready() -> void:
	label.text = sign_text
	interact_area.area_entered.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.connect( player_interact ) )
	interact_area.area_exited.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.disconnect( player_interact ) )





func player_interact() -> void:
	PlayerHud.queue_notification('Табличка', sign_text)
