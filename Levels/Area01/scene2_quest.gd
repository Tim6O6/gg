extends Node2D


signal on_quest_completed

@onready var plants: Node2D = $plants
@onready var quest_advance_trigger: QuestAdvanceTrigger = $QuestAdvanceTrigger


func _ready() -> void:
	var is_activated: bool = await get_parent().is_activated_changed
	
	if is_activated:
		plants.child_exiting_tree.connect(func(_node: Node) -> void:
			if (plants.get_child_count() <= 1):
				await quest_advance_trigger.advance_quest()
				get_parent().queue_free()
		)
