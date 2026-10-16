using Aether.Client.Maps;
using Aether.ClientSim;
using Godot;

namespace Aether.Client.Navigation;

public partial class LocalNavigationController : Node
{
    private NavigationAgent3D _agent = null!;
    private FieldMap _field = null!;
    private Node3D _body = null!;
    private bool _following;

    public string Status { get; private set; } = "idle";

    public Vector3 Destination { get; private set; }

    public bool HasDestination { get; private set; }

    public int PathPointCount { get; private set; }

    public override void _Ready()
    {
        _body = GetParent<Node3D>();
        _agent = GetNode<NavigationAgent3D>("../Navigation");
        _field = GetTree().GetFirstNodeInGroup("field_map") as FieldMap
            ?? throw new System.InvalidOperationException("Field map is missing.");
        _agent.PathDesiredDistance = 0.35f;
        _agent.TargetDesiredDistance = 0.35f;
        _agent.AvoidanceEnabled = false;
        _agent.NavigationLayers = 1;
        var map = _field.Region.GetNavigationMap();
        _agent.SetNavigationMap(map);
#pragma warning disable CS0618
        NavigationServer3D.MapForceUpdate(map);
#pragma warning restore CS0618
    }

    public bool TrySetDestination(Vector3 worldPoint)
    {
        var planar = new PlanarPoint(worldPoint.X, worldPoint.Z);
        if (!_field.Grid.IsWalkable(planar))
        {
            Status = "rejected";
            return false;
        }

        Destination = new Vector3(worldPoint.X, 0f, worldPoint.Z);
        HasDestination = true;
        _following = true;
        Status = "following";
        _agent.TargetPosition = Destination;
        _ = _agent.GetNextPathPosition();
        PathPointCount = _agent.GetCurrentNavigationPath().Length;
        return true;
    }

    public void Cancel()
    {
        _following = false;
        HasDestination = false;
        Status = "idle";
        PathPointCount = 0;
    }

    public Vector2 Step(float speed, float delta)
    {
        if (!_following)
        {
            return Vector2.Zero;
        }

        if (_agent.IsNavigationFinished())
        {
            _following = false;
            Status = "arrived";
            return Vector2.Zero;
        }

        var next = _agent.GetNextPathPosition();
        var path = _agent.GetCurrentNavigationPath();
        PathPointCount = path.Length;
        var from = new PlanarPoint(_body.GlobalPosition.X, _body.GlobalPosition.Z);
        var to = new PlanarPoint(next.X, next.Z);
        var moved = PlanarStep.MoveToward(from, to, Mathf.Max(0f, speed) * Mathf.Max(0f, delta));
        _body.GlobalPosition = new Vector3(moved.X, 0f, moved.Z);
        if (_agent.IsNavigationFinished())
        {
            _following = false;
            Status = "arrived";
        }

        return new Vector2(moved.X - from.X, moved.Z - from.Z);
    }

    public Vector3[] CurrentPath()
    {
        return _agent.GetCurrentNavigationPath();
    }
}
