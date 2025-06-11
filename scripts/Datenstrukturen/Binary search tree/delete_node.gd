extends TextEdit

const TREE_NODE = preload("res://scenes/Datenstrukturen/tree_node.tscn")

func _on_text_changed() -> void:
	if(text.contains( "\n")):
		var input = text.substr(0,text.length() - 1)
		if(!input.is_valid_int()):
			text = ""
			print("wrong input")
			return
		var key = int(input)
		text = ""
		GlobalSignal.deleteNode.emit(key)
