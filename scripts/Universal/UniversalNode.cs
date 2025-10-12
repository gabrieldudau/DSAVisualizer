using Godot;
using System;

[GlobalClass]
public partial class UniversalNode : Node2D
{
	public Label label;

	[Export] public int key;
	[Export] public Color color;
	[Export] public float radius;
	[Export] public int fontSize;


	public override void _Ready()
	{
		label = GetNode<Label>("Label");
		label.Text = key.ToString();
		label.AddThemeFontSizeOverride("font_size", fontSize);
	}


	public override void _Draw()
	{
		GD.Print("Drawing");
		DrawCircle(new Vector2(0, 0), radius, Colors.Black);
		DrawCircle(new Vector2(0, 0), radius - 5, color);
	}

	public void changeText(int key)
    {
		label.Text = key.ToString();
    }

}
