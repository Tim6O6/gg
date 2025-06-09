extends Node2D




func _ready() -> void:
	visible = QuestManager.is_all_quests_completed()
