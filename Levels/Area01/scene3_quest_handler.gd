extends Node2D


const PERSISTENT_DATA_KEY := 'temp/cabbage_collected'
const CABBAGE_REQUIRED: int = 5

@onready var saplings: Node2D = $'../../saplings'
@onready var quest_advance_trigger: QuestAdvanceTrigger = $QuestAdvanceTrigger

var _cabbage_collected: int = 0

func _ready() -> void:
	var is_activated: bool = await get_parent().is_activated_changed
	_cabbage_collected = SaveManager.get_persistent_value(PERSISTENT_DATA_KEY, 0) as int
	if not is_activated or (_cabbage_collected >= CABBAGE_REQUIRED):
		queue_free()
		return
	
	await get_tree().current_scene.ready
	
	saplings.on_sapling_collected.connect(func(sapling: Sapling) -> void:
		if sapling.name == 'Капустное семя': # NOTICE WARNING
			if (_cabbage_collected >= CABBAGE_REQUIRED):
				return
			
			_cabbage_collected += 1
			SaveManager.set_persistent_value(PERSISTENT_DATA_KEY, _cabbage_collected)
			
			if (_cabbage_collected >= CABBAGE_REQUIRED):
				SaveManager.remove_persistent_value(PERSISTENT_DATA_KEY)
				await quest_advance_trigger.advance_quest()
				queue_free()
	)
