extends VBoxContainer

var next_scene = preload("res://scenes/menus/visualization_menu.tscn")

func _on_visualise_mode_pressed() -> void:
	get_tree().change_scene_to_packed(next_scene)
