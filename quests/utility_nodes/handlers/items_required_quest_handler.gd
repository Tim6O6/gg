extends Node2D



@export var item_data: ItemData = null
@export var item_amount_required: int = 1

func _ready() -> void:
	get_parent().finished.connect(func() -> void: # dialog finished
		var item_slots: Array[SlotData] = PlayerManager.INVENTORY_DATA.get_slots_with_item(item_data)
		if item_slots.is_empty():
			return
		
		var items_grabbed: int = 0
		for slot_data: SlotData in item_slots:
			if (items_grabbed >= item_amount_required):
				break
			for i: int in item_amount_required:
				slot_data.quantity -= 1
				items_grabbed += 1
				if (slot_data.quantity <= 0):
					break
		queue_free()
	)
