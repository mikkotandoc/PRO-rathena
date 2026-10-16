namespace Aether.ClientSim;

public sealed class PathFollower
{
    private readonly List<PlanarPoint> _waypoints = new();

    public PathFollower(PlanarPoint position)
    {
        Position = position;
    }

    public PlanarPoint Position { get; private set; }

    public IReadOnlyList<PlanarPoint> Waypoints => _waypoints;

    public bool HasPath => _waypoints.Count > 0 && WaypointIndex < _waypoints.Count;

    public int WaypointIndex { get; private set; }

    public string Status { get; private set; } = "idle";

    public bool TrySetDestination(WalkGrid grid, PlanarPoint destination)
    {
        var path = GridPathfinder.Find(grid, Position, destination);
        if (path.Count == 0)
        {
            Status = "rejected";
            return false;
        }

        _waypoints.Clear();
        _waypoints.AddRange(path);
        WaypointIndex = 0;
        Status = "following";
        return true;
    }

    public float Step(float speed, float delta)
    {
        if (!HasPath)
        {
            return 0f;
        }

        var remaining = MathF.Max(0f, speed) * MathF.Max(0f, delta);
        var moved = 0f;
        while (remaining > 0f && WaypointIndex < _waypoints.Count)
        {
            var before = Position;
            Position = PlanarStep.MoveToward(Position, _waypoints[WaypointIndex], remaining);
            var used = before.DistanceTo(Position);
            moved += used;
            remaining -= used;
            if (Position.DistanceTo(_waypoints[WaypointIndex]) <= 0.001f)
            {
                WaypointIndex++;
            }
            else
            {
                break;
            }
        }

        if (!HasPath)
        {
            Status = "arrived";
        }

        return moved;
    }
}
