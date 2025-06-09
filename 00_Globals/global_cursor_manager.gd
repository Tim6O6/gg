extends Node

enum CursorType { DEFAULT, CLICK, }

signal on_cursor_changed

const DEFAULT_IMAGE = preload('res://assets/cursor/default.png')
const CLICK_IMAGE = preload('res://assets/cursor/click.png')


func reset_cursor():
	Input.set_custom_mouse_cursor(DEFAULT_IMAGE)

func set_cursor(cursor_type: CursorType):
	match cursor_type:
		CursorType.DEFAULT:
			Input.set_custom_mouse_cursor(DEFAULT_IMAGE)
		CursorType.CLICK:
			Input.set_custom_mouse_cursor(CLICK_IMAGE)
		
		
