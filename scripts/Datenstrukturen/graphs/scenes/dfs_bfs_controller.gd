extends SceneMover

@onready var graph: GraphController = $Graph


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	graph.create_new_node(0,0,0, Color.ALICE_BLUE)
	graph.create_new_node(0,0,1, Color.ALICE_BLUE)
	graph.create_new_node(0,0,2, Color.ALICE_BLUE)
	graph.create_new_node(0,0,3, Color.ALICE_BLUE)
	graph.create_new_node(0,0,4, Color.ALICE_BLUE)
	graph.create_new_node(0,0,5, Color.ALICE_BLUE)
	graph.create_new_node(0,0,6, Color.ALICE_BLUE)
	graph.create_new_node(0,0,7, Color.ALICE_BLUE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
