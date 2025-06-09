extends Node2D

signal on_quest_completed

@export var item_data: ItemData = null
@export var signal_object: Node = null
@export var signal_name := ''

func _ready() -> void:
	var is_activated: bool = await get_parent().is_activated_changed
	
	if is_activated:
		signal_object[signal_name].connect(func() -> void:
			PlayerManager.INVENTORY_DATA.add_item(item_data)
		)
