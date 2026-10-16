using Godot;

namespace Aether.Client;

public partial class Main : Node
{
    public override void _Ready()
    {
        GetTree().CallDeferred(SceneTree.MethodName.ChangeSceneToFile, "res://scenes/maps/VerdantTestField.tscn");
    }
}
