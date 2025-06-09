extends Control

const INVENTORY_SLOT = preload("res://GUI/pause_menu/inventory/inventory_slot.tscn")

var focus_index : int = 0
var hovered_item : InventorySlotUI

@export var data : InventoryData



func _ready() -> void:
	#PauseMenu.shown.connect( update_inventory )
	#PauseMenu.hidden.connect( clear_inventory )
	clear_inventory()
	data.on_inventory_changed.connect( on_inventory_changed )
	data.changed.connect( on_inventory_changed )
	data.equipment_changed.connect( on_inventory_changed )
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.set_slot_data( null )


func update_inventory() -> void:
	clear_inventory()
	
	var inventory_slots : Array[ SlotData ] = data.inventory_slots()
	
	for i in get_child_count():
		var slot : InventorySlotUI = get_child( i )
		slot.set_slot_data( inventory_slots[ i ] )
		connect_item_signals( slot )




func item_focused() -> void:
	for i in get_child_count():
		if get_child( i ).has_focus():
			focus_index = i
			return
	pass


func on_inventory_changed() -> void:
	update_inventory()


func connect_item_signals( item : InventorySlotUI ) -> void:
	if not item.button_up.is_connected( _on_item_drop ):
		item.button_up.connect( _on_item_drop.bind( item ) )
	
	if not item.mouse_entered.is_connected( _on_item_mouse_entered ):
		item.mouse_entered.connect( _on_item_mouse_entered.bind( item ) )
	
	if not item.mouse_exited.is_connected( _on_item_mouse_exited ):
		item.mouse_exited.connect( _on_item_mouse_exited )
	pass


func _on_item_drop( item : InventorySlotUI ) -> void:
	if item == null or item == hovered_item or hovered_item == null:
		return
	data.swap_items_by_index( item.get_index(), hovered_item.get_index() )
	update_inventory()
	pass


func _on_item_mouse_entered( item : InventorySlotUI ) -> void:
	CursorManager.set_cursor(CursorManager.CursorType.CLICK)
	hovered_item = item
	pass


func _on_item_mouse_exited() -> void:
	CursorManager.reset_cursor()
	hovered_item = null
	pass






func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed():
		return
	event = (event as InputEventKey)
	
	var key_code := OS.get_keycode_string(event.keycode)
	if key_code.is_valid_int():
		var max_number := get_child_count() + 1
		var key_index = key_code.to_int()
		if (key_index <= max_number):
			update_inventory()
			
			var slot := get_child(key_index - 1) as Control
			if not slot.has_focus():
				slot.grab_focus()
				slot.set_current_item()
			else:
				slot.item_pressed( true )
