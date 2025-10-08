extends VBoxContainer

var bst_scene = preload("res://scenes/bin_search_tree_mode.tscn")

func _on_bst_scene_pressed() -> void:
	get_tree().change_scene_to_packed(bst_scene)
