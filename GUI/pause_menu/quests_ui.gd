class_name QuestsUI extends Control


@onready var quests_vbox: VBoxContainer = %quests_vbox

@onready var description_texture: TextureRect = %description_texture
@onready var description_vbox: VBoxContainer = %description_vbox
@onready var steps_vbox: VBoxContainer = %steps_vbox




func _ready() -> void:
	clear_quest_details()
	visibility_changed.connect( _on_visible_changed )
	hidden.connect( PlayerHud.on_quest_tab_visibility_changed.emit.bind(false) )
	pass


func _clear_cont(cont: Node) -> void:
	for v in cont.get_children():
		if v.name.begins_with('_'):
			v.hide()
			continue
		v.queue_free()


func _on_visible_changed() -> void:
	_clear_cont(quests_vbox)
	clear_quest_details()
	quests_vbox.get_node('_button_tmp').button_pressed = false
	
	PlayerHud.on_quest_tab_visibility_changed.emit(visible)
	
	if visible:
		QuestManager.sort_quests()
		for quest_dict: Dictionary in QuestManager.current_quests:
			var quest_data: Quest = QuestManager.find_quest_by_title( quest_dict.title )
			if not quest_data:
				continue
			var new_quest_item := quests_vbox.get_node('_button_tmp').duplicate()
			new_quest_item.name = quest_data.title
			new_quest_item.show()
			quests_vbox.add_child( new_quest_item )
			new_quest_item.get_node('title_label').text = quest_data.title
			new_quest_item.get_node('step_label').text = 'Шаги: %d / %d' % [quest_dict.completed_steps.size(), quest_data.steps.size()] 
			new_quest_item.focus_entered.connect( update_quest_details.bind( quest_data ) )



func update_quest_details( q : Quest ) -> void:
	clear_quest_details()
	description_texture.show()
	
	#description_vbox.get_node('title_label').text = q.title
	description_vbox.get_node('description_label').text = q.description
	
	var quest_save = QuestManager.find_quest( q )
	
	for step in q.steps:
		var new_step := steps_vbox.get_node('_step_tmp').duplicate()
		new_step.name = step
		new_step.get_node('checkmark').frame = int( quest_save.completed_steps.has( step.to_lower() ) )
		new_step.get_node('label').text = step
		new_step.show()
		steps_vbox.add_child( new_step )
	
	pass


func clear_quest_details() -> void:
	description_vbox.get_node('title_label').text = ""
	description_vbox.get_node('description_label').text = ""
	_clear_cont(steps_vbox)
	description_texture.hide()
