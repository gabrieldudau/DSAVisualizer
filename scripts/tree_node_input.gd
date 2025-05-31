extends TextEdit

const TREE_NODE = preload("res://scenes/tree_node.tscn")

func _on_text_changed() -> void:
	if(text.contains( "\n")):
		var input = text.substr(0,text.length() - 1)
		if(!input.is_valid_int()):
			text = ""
			print("wrong input")
			return
		var treeNode = TREE_NODE.instantiate()
		treeNode.key = int(input)
		text = ""
		GlobalSignal.newNode.emit(treeNode)
		
