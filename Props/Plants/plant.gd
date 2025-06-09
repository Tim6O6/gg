class_name Plant extends Node2D

@onready var animation_player: AnimationPlayer = null


# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = get_node_or_null('AnimationPlayer')
	$HitBox.damaged.connect( take_damage )
	pass # Replace with function body.


func take_damage( _damage : HurtBox ) -> void:
	if animation_player != null:
		animation_player.play("destroy")
		await animation_player.animation_finished
	queue_free()
	pass
