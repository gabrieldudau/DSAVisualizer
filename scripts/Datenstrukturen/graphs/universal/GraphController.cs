using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class GraphController : Node2D
{
    private Node2D springs;
    private Node2D lines;

    /// <summary>
    /// <para>You can use this, to create all the wanted Algorithms. </para> 
    /// <para>Stores the Node, whose children are the actual GraphNodes of the Graph. They are all of the type <see cref="GraphNode"/> </para>
    /// </summary>
    private Node2D nodes;
    Timer ClickTimer;

    private static readonly PackedScene NODE_CLASS = GD.Load<PackedScene>("res://scenes/Datenstrukturen/graphs/universal/graph_node.tscn");
    private const string BODY_GROUP = "celestial_bodies";
    [Export] public float center_stiffness = 10.0f;
    [Export] public float damping_factor = 8.0f;
    [Export] public float repulsion_force = 10;

    private LinkedList<GraphNode> childTouched = new LinkedList<GraphNode>();
    private GraphNode childMoving = null;

    private GraphNode spring1 = null;
    private Dictionary<GraphNode, HashSet<GraphNode>> springs_dict = new Dictionary<GraphNode, HashSet<GraphNode>>();
    private Dictionary<Line2D, GraphNode[]> lineReffrence = new Dictionary<Line2D, GraphNode[]>();

    public override void _Ready()
    {
        springs = GetNode<Node2D>("Springs");
        lines = GetNode<Node2D>("Lines");
        nodes = GetNode<Node2D>("GraphNodes");
        ClickTimer = GetNode<Timer>("ClickTimer");
        this.nodes.ChildEnteredTree += _on_child_entered_tree;
    }

    public void click_started()
    {
        if (childTouched.Count == 0)
        {
            spring1 = null;
            return;
        }
        spring1 = childTouched.First.Value;
    }

    public override void _Input(InputEvent @event)
    {
        if (@event.IsActionPressed("leftMB"))
        {
            click_started();
            ClickTimer.Start();
        }
        if (@event.IsActionReleased("leftMB"))
        {
            var clickTime = ClickTimer.TimeLeft;
            ClickTimer.Stop();
            if (clickTime > 0.0) toggle_child_moving();
            else add_spring();
        }
    }

    public void toggle_child_moving()
    {
        spring1 = null;
        if (childTouched.Count == 0) return;

        if (childMoving == null)
        {
            childMoving = childTouched.First.Value;
            childMoving.Freeze = true;
        }
        else
        {
            childMoving.Freeze = false;
            childMoving = null;
        }
    }

    /// <summary>
    /// Adds a spring between spring1 and childTouched[0], and also adds a Line to the Graph. A refrence to the line is stored in both kids. 
    /// </summary>
    public void add_spring()
    {
        if (spring1 == null || childTouched.Count == 0 || spring1 == childTouched.First.Value) return;

        if (!springs_dict.ContainsKey(spring1))
        {
            springs_dict[spring1] = new HashSet<GraphNode>();

        }

        if (springs_dict[spring1].Contains(childTouched.First.Value))
        {
            return;
        }
        springs_dict[spring1].Add(childTouched.First.Value);


        if (!springs_dict.ContainsKey(childTouched.First.Value))
        {
            springs_dict[childTouched.First.Value] = new HashSet<GraphNode>();
        }
        springs_dict[childTouched.First.Value].Add(spring1);

        DampedSpringJoint2D newSpring = new DampedSpringJoint2D();
        newSpring.NodeA = spring1.GetPath();
        newSpring.NodeB = childTouched.First.Value.GetPath();
        newSpring.RestLength = 500;
        springs.AddChild(newSpring);
        Line2D line = new Line2D();
        line.AddPoint(spring1.Position);
        line.AddPoint(childTouched.First.Value.Position);
        lineReffrence[line] = new GraphNode[] { spring1, childTouched.First.Value };
        lines.AddChild(line);
    }

    public void create_new_node(int posX, int posY, int key, Color color)
    {
        GraphNode createNode = NODE_CLASS.Instantiate<GraphNode>();
        createNode.Position = new Godot.Vector2(posX, posY);
        createNode.key = key;
        createNode.color = color;
        nodes.AddChild(createNode);
    }

    public override void _Process(double delta)
    {
        foreach (Line2D line in lines.GetChildren())
        {
            line.SetPointPosition(0, lineReffrence[line][0].Position);
            line.SetPointPosition(1, lineReffrence[line][1].Position);
        }
    }


    public override void _PhysicsProcess(double delta)
    {
        // 1. SETUP & MOUSE HANDLING
        var bodyNodes = GetTree().GetNodesInGroup(BODY_GROUP);

        var camera = GetViewport().GetCamera2D();
        Vector2 screenCenter = camera != null ? camera.GetScreenCenterPosition() : GetViewportRect().Size / 2;

        // Handle mouse dragging first
        if (childMoving != null)
        {
            childMoving.Position = GetGlobalMousePosition();
            // Reset velocity so it doesn't "explode" when released
            if (childMoving is RigidBody2D rbChild)
            {
                rbChild.LinearVelocity = Vector2.Zero;
                rbChild.AngularVelocity = 0;
            }
        }

        // 2. READ PHASE (Cache Data)
        int count = bodyNodes.Count;
        var activeBodies = new List<RigidBody2D>(count);
        var positions = new List<Vector2>(count);
        var velocities = new List<Vector2>(count);
        var forces = new List<Vector2>(count);

        for (int i = 0; i < count; i++)
        {
            // Skip the child being dragged or non-rigidbodies
            if (bodyNodes[i] is RigidBody2D rb && rb != childMoving)
            {
                // API Calls are more expensive than natice C#
                activeBodies.Add(rb);
                positions.Add(rb.GlobalPosition);   
                velocities.Add(rb.LinearVelocity);  
                forces.Add(Vector2.Zero);           
            }
        }

        int activeCount = activeBodies.Count;

        // 3. CALCULATION PHASE (Pure C# Math - No API Calls)
        for (int i = 0; i < activeCount; i++)
        {
            Vector2 posA = positions[i];
            Vector2 forceAccum = forces[i]; // Start with current accumulated force

            // --- A. Center Attraction & Damping ---
            Vector2 toCenter = screenCenter - posA;
            forceAccum += toCenter * center_stiffness;
            forceAccum += -velocities[i] * damping_factor;

            // --- B. Repulsion (N^2 Loop) ---
            for (int j = i + 1; j < activeCount; j++)
            {
                Vector2 posB = positions[j];
                Vector2 vectorBetween = posB - posA;

                float distSq = vectorBetween.LengthSquared();

                if (distSq < 1.0f) distSq = 1.0f;

                // Calculate the scaling factor based on squared distance
                float strengthFactor = (repulsion_force * 10000.0f) / distSq;

                Vector2 repulsionVector = vectorBetween * strengthFactor;

                forceAccum -= repulsionVector;

                
                forces[j] += repulsionVector;
            }

            forces[i] = forceAccum;
        }

        // 4. WRITE PHASE (Apply to Engine)
        for (int i = 0; i < activeCount; i++)
        {
            activeBodies[i].ApplyCentralForce(forces[i]);
        }
    }

    private void _on_child_entered_tree(Node node)
    {
        if (node is GraphNode graphNode)
        {
            graphNode.InputPickable = true;
            graphNode.MouseEntered += () => _mouse_touching_node(graphNode);
            graphNode.MouseExited += () => _mouse_not_touching_node(graphNode);
        }
    }

    private void _mouse_touching_node(GraphNode node)
    {
        childTouched.AddFirst(node);
    }



    private void _mouse_not_touching_node(GraphNode node)
    {
        if (childTouched.Count > 0)
        {
            childTouched.RemoveLast();
        }
    }
}