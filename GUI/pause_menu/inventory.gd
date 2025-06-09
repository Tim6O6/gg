extends Control





func _ready() -> void:
	visibility_changed.connect(func() -> void:
		PlayerHud.on_backpack_tab_visibility_changed.emit(visible)
	)
	hidden.connect( PlayerHud.on_backpack_tab_visibility_changed.emit.bind(false) )
