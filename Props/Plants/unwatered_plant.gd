extends Area2D


signal on_watered()


@onready var sprite: Sprite2D = $sprite_node/sprite
@onready var ap: AnimationPlayer = $ap



var _is_watered := false

func _ready() -> void:
	_is_watered = SaveManager.get_persistent_value(str(get_path()), false)
	_update()
	
	if _is_watered:
		return
	
	self.area_entered.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.connect( player_interact ) )
	self.area_exited.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.disconnect( player_interact ) )





func player_interact() -> void:
	if _is_watered:
		return
	
	var current_item_slot_data: SlotData = PlayerManager.INVENTORY_DATA.get_current_slot()
	if not current_item_slot_data or not current_item_slot_data.item_data:
		return
	if current_item_slot_data.item_data.name != 'Лейка': # NOTICE WARNING
		return
	
	current_item_slot_data.quantity -= 1
	PlayerManager.INVENTORY_DATA.on_inventory_changed.emit()
	_is_watered = true
	SaveManager.add_persistent_value(str(get_path()), true)
	_update()
	on_watered.emit()




func _update() -> void:
	ap.play(&'watered' if _is_watered else &'RESET')
