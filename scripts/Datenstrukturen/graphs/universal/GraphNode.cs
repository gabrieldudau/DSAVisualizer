using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class GraphNode : RigidBody2D
{

	public UniversalNode bodyNode;
	public CollisionShape2D col;
	public List<Line2D> lines;
	public int key;
	public Color color;

	public override void _Ready()
	{
		col = GetNode<CollisionShape2D>("CollisionShape2D");
		bodyNode = GetNode<UniversalNode>("universal_node");
		CircleShape2D shape = new CircleShape2D();
		shape.Radius = bodyNode.radius;
		col.Shape = shape;
		bodyNode.color = color;
		bodyNode.changeText(key);
	}

	public void ChangeColor(Color color)
	{
		bodyNode.color = color;
	}

}
