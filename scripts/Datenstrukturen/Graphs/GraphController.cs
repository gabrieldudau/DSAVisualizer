using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class GraphController : Node2D
{
    private Node2D springs;

    private static readonly PackedScene NODE_CLASS = GD.Load<PackedScene>("res://scenes/Datenstrukturen/Graphs/graph_node.tscn");
    private const string BODY_GROUP = "celestial_bodies";
    [Export] public float center_stiffness = 10.0f;
    [Export] public float damping_factor = 8.0f;

    private LinkedList<RigidBody2D> childTouched = new LinkedList<RigidBody2D>();
    private RigidBody2D childMoving = null;

    private RigidBody2D spring1 = null;
    private Dictionary<RigidBody2D, HashSet<RigidBody2D>> springs_dict = new Dictionary<RigidBody2D, HashSet<RigidBody2D>>();

    public override void _Ready()
    {
        // FIX: Initialize node references and connect signals here.
        springs = GetNode<Node2D>("Springs");
        this.ChildEnteredTree += _on_child_entered_tree;
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

    public void toggle_child_moving()
    {
        spring1 = null;
        if (childTouched.Count == 0) return;
        
        // FIX: The logic was reversed and would cause a crash.
        // This now correctly matches the GDScript version.
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

    public void add_spring()
    {
        if (spring1 == null || childTouched.Count == 0 || spring1 == childTouched.First.Value) return;
        
        // Create the entry if it doesn't exist.
        if (!springs_dict.ContainsKey(spring1))
        {
            springs_dict[spring1] = new HashSet<RigidBody2D>();
        }

        // Check if the connection already exists.
        // FIX: Use .Add() for HashSet, not .Append(). And check for existence before adding.
        if (springs_dict[spring1].Contains(childTouched.First.Value))
        {
            return;
        }
        
        springs_dict[spring1].Add(childTouched.First.Value);

        // --- Handle the reverse connection ---
        if (!springs_dict.ContainsKey(childTouched.First.Value))
        {
            springs_dict[childTouched.First.Value] = new HashSet<RigidBody2D>();
        }
        // FIX: Use .Add() here as well.
        springs_dict[childTouched.First.Value].Add(spring1);

        DampedSpringJoint2D newSpring = new DampedSpringJoint2D();
        newSpring.NodeA = spring1.GetPath();
        newSpring.NodeB = childTouched.First.Value.GetPath();
        newSpring.RestLength = 500;
        springs.AddChild(newSpring);
    }

    public void create_new_node(int posX, int posY, string text)
    {
        RigidBody2D createNode = NODE_CLASS.Instantiate<RigidBody2D>();
        createNode.Position = new Godot.Vector2(posX, posY);
        AddChild(createNode);
    }

    public override void _PhysicsProcess(double delta)
    {
        // FIX: base._PhysicsProcess(delta) is not needed as Node2D has no implementation for it.
        
        var bodies = GetTree().GetNodesInGroup(BODY_GROUP);
        
        var camera = GetViewport().GetCamera2D();
        Vector2 screenCenter = camera != null ? camera.GetScreenCenterPosition() : GetViewportRect().Size / 2;

        if (childMoving != null)
        {
            childMoving.Position = GetGlobalMousePosition();
        }

        foreach (Node body in bodies)
        {
            if (body == childMoving)
            {
                continue;
            }

            if (body is RigidBody2D rigidBody)
            {
                Vector2 toCenterVector = screenCenter - rigidBody.GlobalPosition;
                
                // Attraction Force
                Vector2 attractionForce = toCenterVector * center_stiffness;
                rigidBody.ApplyCentralForce(attractionForce);

                // Damping Force
                Vector2 dragForce = -rigidBody.LinearVelocity * damping_factor;
                rigidBody.ApplyCentralForce(dragForce);
            }
        }
    }

    private void _on_child_entered_tree(Node node)
    {
        if (node is RigidBody2D rigidBody)
        {
            rigidBody.InputPickable = true;
            rigidBody.MouseEntered += () => _mouse_touching_node(rigidBody);
            rigidBody.MouseExited += () => _mouse_not_touching_node(rigidBody);
        }
    }

    private void _mouse_touching_node(RigidBody2D node)
    {
        childTouched.AddFirst(node);
        GD.Print(childTouched.First.Value.ToString());
    }

    private void _mouse_not_touching_node(RigidBody2D node)
    {
        if (childTouched.Count > 0)
        {
            childTouched.RemoveLast();
        }
    }
}