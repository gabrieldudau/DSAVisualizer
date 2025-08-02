extends Node2D

const LIST_ITEM = preload("res://scenes/Datenstrukturen/list_item.tscn")
var items:Array[ListItem]

func add_new_item(new_text:String):
	var new_item = LIST_ITEM.instantiate();
	new_item.content_string = new_text;
	if(items.is_empty()):
		new_item.position = Vector2(0,0)
	else:
		var last_item = items[-1]
		new_item.position = last_item.position + Vector2(last_item.get_current_size().x + 20, 0)
	items.append(new_item)
	add_child(new_item)
