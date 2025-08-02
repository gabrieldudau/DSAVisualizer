extends TextEdit

@onready var list: Node2D = $"../List"


func _on_text_changed() -> void:
	if(text.contains( "\n")):
		var input = text.substr(0,text.length() - 1)
		list.add_new_item(input)
		text = ""
	
	
