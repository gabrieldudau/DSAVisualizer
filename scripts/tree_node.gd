class_name TreeNode
extends Node2D

@onready var label: Label = $Label
@onready var weiß: Sprite2D = $weiß
@onready var gelb: Sprite2D = $gelb

var left:TreeNode
var right:TreeNode
var parent:TreeNode
var key: int
var connection_line:Line2D
var positions_list:Array
var time:Timer = Timer.new()


func _on_ready() -> void:
	label.text = str(key)
	gelb.hide()
	weiß.show()
	add_child(time)

func connect_line():
	if(parent == null):
		return
	connection_line = Line2D.new()
	connection_line.add_point(Vector2(0,0))
	connection_line.add_point(parent.position - position)
	connection_line.z_index = -1
	connection_line.default_color = Color.BLACK
	add_child(connection_line)

func move_to_right_position(speed) -> void:
	if positions_list.is_empty():
		return
	
	position = positions_list.pop_front()
	while not positions_list.is_empty():
		var position_to_reach:Vector2 = positions_list.pop_front()
		var vector_to_new_position:Vector2 = position_to_reach - position
		var distance = position.distance_to(position_to_reach)
		while distance > 1:
			var delta_time = get_process_delta_time()
			var movement_this_frame = vector_to_new_position.normalized() * speed * delta_time # Normalize for consistent speed
			position += movement_this_frame
			var old_distance = distance
			distance = position.distance_to(position_to_reach) # Update distance
			if (distance > old_distance):
				break
			await get_tree().process_frame
		position = position_to_reach
	connect_line()

func light_up_for_search():
	weiß.hide()
	gelb.show()
	if connection_line != null:
		connection_line.default_color = Color.ORANGE_RED
	time.start(3)
	await time.timeout
	weiß.show()
	gelb.hide()
	if connection_line != null:
		connection_line.default_color = Color.BLACK
	
