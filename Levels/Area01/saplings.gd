extends Node2D


signal on_sapling_grown(sapling: Sapling)
signal on_sapling_collected(sapling: Sapling)

var data: Dictionary[int, Sapling] = {}

const GRID_ITEM_SIZE := (Vector2.ONE * 20)
const GRID_ITEMS: int = 16
const GRID_PADDING: int = 10
const GRID_COLUMNS: int = 4

func _ready() -> void:
	_make_saplings_grid()
	load_data()

func _make_saplings_grid() -> void:
	_reset_saplings()
	
	for i: int in GRID_ITEMS:
		var new_sapling_node := get_node('_sapling_tmp').duplicate()
		new_sapling_node.name = str(i)
		new_sapling_node.show()
		add_child(new_sapling_node)
		new_sapling_node.position = Vector2(
			(i % GRID_COLUMNS) * (GRID_ITEM_SIZE.x + GRID_PADDING),
			floorf(i / GRID_COLUMNS) * (GRID_ITEM_SIZE.y + GRID_PADDING),
		)
		new_sapling_node.on_update.connect(save_data)
		new_sapling_node.on_collected.connect(on_sapling_collected.emit)


func _reset_saplings() -> void:
	for v: Node2D in get_children():
		if v.name.begins_with('_'):
			v.hide()
			continue
		v.queue_free()


func load_data() -> void:
	SaveManager.current_save.saplings = SaveManager.current_save.get('saplings', {})
	if SaveManager.current_save.saplings.is_empty():
		return
	
	data.clear()
	
	for index: int in SaveManager.current_save.saplings:
		var value: Dictionary = SaveManager.current_save.saplings[index]
		var sapling := ResourceLoader.load(value.resource_path) as Sapling
		
		sapling.grow_level = value.get('grow_level', 1)
		data[index] = sapling
		
		var sapling_node := get_node_or_null(str(index))
		if sapling_node != null:
			sapling_node.start_growing(sapling)


func save_data() -> void:
	SaveManager.current_save.saplings.clear()
	data.clear()
	
	for node: Node2D in get_children():
		if not node.sapling:
			continue
		
		var index: int = node.name.to_int()
		var sapling := node.sapling as Sapling
		data[index] = node.sapling
		
		var json_data := {
			resource_path = sapling.get_meta('default_resource_path'), # export
			grow_level = sapling.grow_level,
		}
		SaveManager.current_save.saplings[index] = json_data


func remove_sapling(index: int) -> void:
	SaveManager.current_save.saplings = SaveManager.current_save.get('saplings', {})
	if SaveManager.current_save.saplings.is_empty():
		return
	if SaveManager.current_save.saplings.has(index):
		SaveManager.current_save.saplings.erase(index)
