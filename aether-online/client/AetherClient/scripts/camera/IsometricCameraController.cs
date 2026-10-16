using Aether.ClientSim;
using Godot;

namespace Aether.Client.Camera;

public partial class IsometricCameraController : Node3D
{
    private readonly IsometricCameraRig _rig = new();
    private Camera3D _camera = null!;
    private Node3D? _target;

    public IsometricCameraRig Rig => _rig;

    public float OrthographicSize => _rig.OrthographicSize;

    public float YawDegrees => _rig.YawDegrees;

    public override void _Ready()
    {
        _camera = GetNode<Camera3D>("Camera");
        _camera.Projection = Camera3D.ProjectionType.Orthogonal;
        _camera.Current = true;
        Apply();
    }

    public void Follow(Node3D target)
    {
        _target = target;
        SnapToTarget();
    }

    public void SnapToTarget()
    {
        if (_target is null)
        {
            return;
        }

        _rig.SnapTo(_target.GlobalPosition.X, 0f, _target.GlobalPosition.Z);
        Apply();
    }

    public void ZoomBy(float notches)
    {
        _rig.ZoomBy(notches);
        Apply();
    }

    public void RotateQuarter(int turns)
    {
        _rig.RotateQuarter(turns);
        Apply();
    }

    public override void _Process(double delta)
    {
        if (_target is null)
        {
            return;
        }

        _rig.Follow(_target.GlobalPosition.X, 0f, _target.GlobalPosition.Z, (float)delta);
        Apply();
    }

    private void Apply()
    {
        GlobalPosition = new Vector3(_rig.FocusX, _rig.FocusY, _rig.FocusZ);
        _camera.RotationDegrees = new Vector3(_rig.PitchDegrees, _rig.YawDegrees, 0f);
        _camera.Position = _camera.Basis.Z * _rig.Distance;
        _camera.Size = _rig.OrthographicSize;
        _camera.Near = 0.05f;
        _camera.Far = _rig.FarClip;
    }
}
