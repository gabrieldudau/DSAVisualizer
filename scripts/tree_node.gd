extends Node2D

@onready var label: Label = $Label

var left 
var right 
var parent
var key: int
var connection_line:Line2D

var positions_list:Array

func _on_ready() -> void:
	label.text = str(key)

func connect_line():
	if(parent == null):
		return
	connection_line = Line2D.new()
	connection_line.add_point(Vector2(0,0))
	connection_line.add_point(parent.position - position)
	connection_line.z_index = -1
	connection_line.default_color = Color.BLACK
	add_child(connection_line)

func move_to_right_position(speed: float): # Changed speed to float for more precision
	if positions_list.is_empty():
		return # Nothing to do if the list is empty

	position = positions_list.pop_front()

	while not positions_list.is_empty():
		var position_to_reach = positions_list.pop_front()
		var vector_to_new_position = position_to_reach - position
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
