extends SceneMover

@onready var graph: GraphController = $Graph
@onready var h_slider: HSlider = $CanvasLayer/VBoxContainer/HSlider
@onready var label: Label = $CanvasLayer/Container/Label

var num = 0

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)
	label.text = str(get_tree().get_nodes_in_group("celestial_bodies").size())

func _on_button_pressed() -> void:
	for i in range(0,50):
		graph.create_new_node(randi() % 1000, randi() % 1500, num, Color.ALICE_BLUE)
		num += 1

func _on_camera_move_pressed() -> void:
	moveable = not moveable

func _on_h_slider_2_value_changed(value: float) -> void:
	graph.repulsion_force = value;


func _on_h_slider_value_changed(value: float) -> void:
	var val = h_slider.value
	graph.center_stiffness= val
	print(val)
