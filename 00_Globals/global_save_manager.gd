extends Node

const SAVE_PATH = "user://"


signal game_loaded
signal game_saved


var current_save : Dictionary = {
	scene_path = "",
	player = {
		level = 1,
		xp = 0,
		hp = 1,
		max_hp = 1,
		attack = 1,
		defense = 1,
		pos_x = 0,
		pos_y = 0
	},
	saplings = {}, # Dictionary[int, Dictionary]
	# { 2 = { name = 'plant', grow_level = 1 } }
	items = [],
	persistence = {},
	quests = [
		#{ title = "не найдено", is_complete = false, completed_steps = [''] }
	],
}




func save_game() -> void:
	update_player_data()
	update_scene_path()
	update_item_data()
	update_quest_data()
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( current_save )
	file.store_line( save_json )
	game_saved.emit()
	pass


func get_save_file() -> FileAccess:
	return FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )



func load_game() -> void:
	var file := get_save_file()
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	
	if typeof(current_save.persistence) == TYPE_ARRAY: # TEST NOTICE MIGRATE
		current_save.persistence = {}
	
	var scene_path: String = current_save.get('scene_path', '') as String
	if scene_path.is_empty() or not scene_path.contains('/scene'):
		scene_path = 'res://Levels/Area01/scene1.tscn'
	
	LevelManager.load_new_level( scene_path, "", Vector2.ZERO )
	
	await LevelManager.level_load_started
	
	#PlayerManager.set_player_position( Vector2( current_save.player.pos_x, current_save.player.pos_y ) )
	PlayerManager.set_health( current_save.player.hp, current_save.player.max_hp )
	
	var p : Player = PlayerManager.player
	p.level = current_save.player.level
	p.xp = current_save.player.xp
	p.attack = current_save.player.attack
	p.defense = current_save.player.defense
	
	PlayerManager.INVENTORY_DATA.parse_save_data( current_save.items )
	QuestManager.current_quests = current_save.quests
	
	await LevelManager.level_loaded
	
	game_loaded.emit()
	
	pass


func update_player_data() -> void:
	var p : Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	current_save.player.level = p.level
	current_save.player.xp = p.xp
	current_save.player.attack = p.attack
	current_save.player.defense = p.defense


func update_scene_path() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p


func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()



func update_quest_data() -> void:
	current_save.quests = QuestManager.current_quests



func add_persistent_value( key : String, value: Variant ) -> void:
	if get_persistent_value( key ) == null:
		current_save.persistence[key] = value

func set_persistent_value( key : String, value: Variant ) -> void:
	if get_persistent_value( key ) != null:
		current_save.persistence[key] = value


func get_persistent_value( key : String, default: Variant = null ) -> Variant:
	return current_save.persistence.get(key, default)


func remove_persistent_value( key : String ) -> void:
	if current_save.persistence.has(key):
		current_save.persistence.erase(key)
