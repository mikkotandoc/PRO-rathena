using Aether.ClientSim;
using Godot;

namespace Aether.Client.Player;

public partial class CharacterAnimationController : Node
{
    private readonly CharacterAnimationLogic _logic = new();
    private AnimatedSprite3D _sprite = null!;
    private string _playing = string.Empty;

    public LocomotionState State => _logic.State;

    public Facing8 Facing => _logic.Facing;

    public string AnimationName => _logic.AnimationName;

    public bool IsDead => _logic.IsDead;

    public override void _Ready()
    {
        _sprite = GetNode<AnimatedSprite3D>("../Visual");
    }

    public void SetPlanarVelocity(float x, float z)
    {
        _logic.SetPlanarVelocity(x, z);
    }

    public void RequestAttack()
    {
        _logic.RequestAttack();
    }

    public void RequestDeath()
    {
        _logic.RequestDeath();
    }

    public void Revive()
    {
        _logic.Revive();
    }

    public override void _Process(double delta)
    {
        _logic.Tick((float)delta);
        if (_sprite.SpriteFrames is null)
        {
            return;
        }

        if (_playing != _logic.AnimationName)
        {
            _playing = _logic.AnimationName;
            _sprite.Animation = _playing;
        }

        var frameCount = _sprite.SpriteFrames.GetFrameCount(_playing);
        if (frameCount > 0)
        {
            _sprite.Frame = Mathf.Clamp(_logic.Frame, 0, frameCount - 1);
        }
    }
}
