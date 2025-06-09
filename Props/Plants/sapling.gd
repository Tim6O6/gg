extends Area2D


signal on_update()
signal on_grown(sapling: Sapling)
signal on_collected(sapling: Sapling)


const SPRITE_REGION_POSITION := Vector2(32, 112)
const SPRITE_REGION_SIZE: int = 16


@export var sapling: Sapling = null
@export var region_sprite_index: int = 0:
	set(value):
		region_sprite_index = value
		_update_sprite_region()

@onready var sprite: Sprite2D = $sprite_node/sprite
@onready var ap: AnimationPlayer = $ap


var _index: int = 0
var _default_texture_region := Rect2i()
var _grow_timer: Timer = null



func _ready() -> void:
	clear()
	
	self.area_entered.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.connect( player_interact ) )
	self.area_exited.connect(func( _area: Area2D ) -> void:
		PlayerManager.interact_pressed.disconnect( player_interact ) )


func start_growing(new_sapling: Sapling) -> void:
	sapling = new_sapling.duplicate()
	
	sapling.grow_level = new_sapling.grow_level
	sapling.set_meta('default_resource_path', new_sapling.resource_path)
	
	_grow_timer = Timer.new()
	_grow_timer.wait_time = (sapling.grow_time / sapling.grow_levels)
	_grow_timer.one_shot = false
	add_child(_grow_timer)
	_grow_timer.timeout.connect(_on_grow_timer_timeout)
	_grow_timer.start()
	sprite.show()
	
	sprite.texture = sapling.texture.duplicate()
	_default_texture_region = (sprite.texture as AtlasTexture).region
	
	sapling.on_grow_level_updated.connect(_update_state.unbind(1))
	sapling.on_grown.connect(_on_grown)
	
	_update_sprite_region()



func _on_grow_timer_timeout() -> void:
	if not sapling.grow():
		_grow_timer.stop()
		return

func _on_grown() -> void:
	ap.play(&'grown')
	on_grown.emit(sapling)

func _update_sprite_region() -> void:
	if not sprite: # from setter
		return
	
	var sprite_texture := sprite.texture as AtlasTexture
	sprite_texture.region = Rect2(
		Vector2(
			_default_texture_region.position.x + ((sapling.grow_level - 1) * SPRITE_REGION_SIZE),
			_default_texture_region.position.y,
		),
		Vector2.ONE * SPRITE_REGION_SIZE
	)

func _update_state() -> void:
	_update_sprite_region()
	on_update.emit()






func player_interact() -> void:
	if sapling != null:
		if sapling.is_grown():
			collect()
			return
	else:
		var current_item_slot_data: SlotData = PlayerManager.INVENTORY_DATA.get_current_slot()
		if not current_item_slot_data or not current_item_slot_data.item_data:
			return
		if not (current_item_slot_data.item_data is Sapling):
			return
		
		current_item_slot_data.quantity -= 1
		PlayerManager.INVENTORY_DATA.on_inventory_changed.emit()
		start_growing(current_item_slot_data.item_data)
		on_update.emit()




func collect() -> void:
	PlayerManager.reward_xp( sapling.grow_reward_xp )
	for v: QuestRewardItem in sapling.grow_rewards:
		PlayerManager.INVENTORY_DATA.add_item( v.item, v.quantity )
	
	on_collected.emit(sapling)
	clear()
	on_update.emit()


func clear() -> void:
	if _grow_timer != null:
		_grow_timer.queue_free()
		_grow_timer = null
	sapling = null
	_default_texture_region = Rect2i()
	ap.play(&'RESET')
	sprite.hide()
