using Aether.Client.Navigation;
using Aether.ClientSim;
using Godot;

namespace Aether.Client.Player;

public partial class PlayerController : Node3D
{
    [Export]
    public float MoveSpeed { get; set; } = 6f;

    private LocalNavigationController _navigation = null!;
    private CharacterAnimationController _animation = null!;
    private IsometricCameraRig _cameraRig = null!;
    private Vector2 _directMove;

    public LocalNavigationController Navigation => _navigation;

    public CharacterAnimationController Animation => _animation;

    public override void _Ready()
    {
        _navigation = GetNode<LocalNavigationController>("NavigationController");
        _animation = GetNode<CharacterAnimationController>("Animation");
    }

    public void BindCamera(IsometricCameraRig rig)
    {
        _cameraRig = rig;
    }

    public void OnDestinationPicked(Vector3 worldPosition)
    {
        if (_animation.IsDead)
        {
            return;
        }

        _navigation.TrySetDestination(worldPosition);
    }

    public void OnDestinationRejected(Vector3 worldPosition)
    {
    }

    public void OnDirectMove(Vector2 cameraRelative)
    {
        _directMove = cameraRelative;
    }

    public void OnAttackPressed()
    {
        _animation.RequestAttack();
    }

    public void OnDeathPressed()
    {
        _navigation.Cancel();
        _animation.RequestDeath();
    }

    public void OnRevivePressed()
    {
        _animation.Revive();
    }

    public override void _PhysicsProcess(double delta)
    {
        SimulateStep((float)delta);
    }

    public void SimulateStep(float delta)
    {
        if (_animation.IsDead)
        {
            _animation.SetPlanarVelocity(0f, 0f);
            return;
        }

        Vector2 moved;
        if (_directMove.LengthSquared() > 0.01f && _cameraRig is not null)
        {
            _navigation.Cancel();
            var wish = _cameraRig.CameraRelativeMove(_directMove.X, _directMove.Y);
            var from = new PlanarPoint(GlobalPosition.X, GlobalPosition.Z);
            var length = Mathf.Sqrt((wish.X * wish.X) + (wish.Z * wish.Z));
            var direction = length <= 0.001f ? wish : new PlanarPoint(wish.X / length, wish.Z / length);
            var to = new PlanarPoint(from.X + direction.X, from.Z + direction.Z);
            var next = PlanarStep.MoveToward(from, to, MoveSpeed * delta);
            GlobalPosition = new Vector3(next.X, 0f, next.Z);
            moved = new Vector2(next.X - from.X, next.Z - from.Z);
        }
        else
        {
            moved = _navigation.Step(MoveSpeed, delta);
        }

        var inv = delta <= 0.0001f ? 0f : 1f / delta;
        _animation.SetPlanarVelocity(moved.X * inv, moved.Y * inv);
    }
}
