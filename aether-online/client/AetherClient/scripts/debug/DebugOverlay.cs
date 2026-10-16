using Aether.Client.Navigation;
using Aether.Client.Player;
using Godot;

namespace Aether.Client.Debug;

public partial class DebugOverlay : CanvasLayer
{
    private Label _readout = null!;
    private PlayerController _player = null!;
    private LocalNavigationController _navigation = null!;
    private CharacterAnimationController _animation = null!;

    public override void _Ready()
    {
        _readout = GetNode<Label>("Readout");
        _player = GetNode<PlayerController>("../Player");
        _navigation = _player.Navigation;
        _animation = _player.Animation;
    }

    public override void _Process(double delta)
    {
        var destination = _navigation.HasDestination
            ? $"{_navigation.Destination.X:0.00}, {_navigation.Destination.Z:0.00}"
            : "none";
        _readout.Text =
            $"Verdant Test Field\n" +
            $"position {_player.GlobalPosition.X:0.00}, {_player.GlobalPosition.Z:0.00}\n" +
            $"destination {destination}\n" +
            $"navigation {_navigation.Status} points={_navigation.PathPointCount}\n" +
            $"fps {Engine.GetFramesPerSecond():0}\n" +
            $"animation {_animation.AnimationName}";
    }
}
