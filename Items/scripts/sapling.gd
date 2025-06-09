extends ItemData
class_name Sapling

signal on_grow_level_updated(level: int)
signal on_grown()


@export var grow_levels: int = 8
@export var grow_time: float = 15.0 # secs

@export_category('Rewards')
@export var grow_reward_xp: int = 100
@export var grow_rewards: Array[QuestRewardItem] = []

var grow_level: int = 1 # starts from 1



func grow() -> bool:
	if is_grown():
		return false
	
	grow_level = mini(grow_level + 1, grow_levels)
	on_grow_level_updated.emit(grow_level)
	if is_grown():
		on_grown.emit()
	return true

func is_grown() -> bool:
	return (grow_level >= grow_levels)


func collect() -> void:
	pass



func get_data() -> Dictionary:
	return {
		grow_level = grow_level,
	}
