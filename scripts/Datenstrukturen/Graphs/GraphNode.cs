using Godot;
using System;

[GlobalClass]
public partial class GraphNode : RigidBody2D
{

	public UniversalNode BodyNode;
	public CollisionShape2D col;

	public override void _Ready()
	{
		col = GetNode<CollisionShape2D>("CollisionShape2D");
		BodyNode = GetNode<UniversalNode>("universal_node");
		CircleShape2D shape = new CircleShape2D();
		shape.Radius = BodyNode.radius;
		col.Shape = shape;
		BodyNode.changeText(5);
	}

	public void ChangeColor()
    {
        
    }

}
