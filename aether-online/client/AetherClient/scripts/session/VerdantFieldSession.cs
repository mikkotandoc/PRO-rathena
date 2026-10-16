using Aether.Client.Camera;
using Aether.Client.Input;
using Aether.Client.Maps;
using Aether.Client.Player;
using Aether.ClientSim;
using Aether.Contracts;
using Aether.GameRules;
using Godot;

namespace Aether.Client.Session;

public partial class VerdantFieldSession : Node3D
{
    private FieldMap _field = null!;
    private PlayerController _player = null!;
    private ClickToMoveInput _input = null!;
    private IsometricCameraController _camera = null!;
    private bool _harness;
    private int _physicsFrames;
    private bool _harnessStarted;

    public override void _Ready()
    {
        _field = GetNode<FieldMap>("Field");
        _player = GetNode<PlayerController>("Player");
        _input = GetNode<ClickToMoveInput>("ClickInput");
        _camera = GetNode<IsometricCameraController>("CameraRig");
        var start = _field.Grid.CellCenter(
            CellOf(_field.Grid, _field.Layout.PlayerStart).Column,
            CellOf(_field.Grid, _field.Layout.PlayerStart).Row);
        _player.GlobalPosition = new Vector3(start.X, 0f, start.Z);
        _player.BindCamera(_camera.Rig);
        _camera.Follow(_player);
        _input.DestinationPicked += _player.OnDestinationPicked;
        _input.DirectMoveChanged += _player.OnDirectMove;
        _input.AttackPressed += _player.OnAttackPressed;
        _input.DeathPressed += _player.OnDeathPressed;
        _input.RevivePressed += _player.OnRevivePressed;
        _input.ZoomRequested += _camera.ZoomBy;
        _input.RotateRequested += _camera.RotateQuarter;
        _harness = false;
        foreach (var arg in OS.GetCmdlineUserArgs())
        {
            if (arg == "--nav-harness")
            {
                _harness = true;
            }
        }

        if (_harness)
        {
            _player.SetPhysicsProcess(false);
        }

        var level = System.Environment.GetEnvironmentVariable("AETHER_LOG_LEVEL");
        if (string.IsNullOrWhiteSpace(level))
        {
            level = "Information";
        }

        var mainScene = ProjectSettings.GetSetting("application/run/main_scene").AsString();
        GD.Print($"[{level}] AetherClient ready role=client protocol={ProtocolVersion.Major}.{ProtocolVersion.Minor} map={_field.Layout.Id} player=1 rules={EmptyRuleCatalog.Instance.Modules.Count} main_scene={mainScene}");
    }

    public override void _PhysicsProcess(double delta)
    {
        if (!_harness || _harnessStarted)
        {
            return;
        }

        _physicsFrames++;
        if (_physicsFrames < 8)
        {
            return;
        }

        _harnessStarted = true;
        var code = RunHarness();
        GetTree().Quit(code);
    }

    private int RunHarness()
    {
#pragma warning disable CS0618
        NavigationServer3D.MapForceUpdate(_field.Region.GetNavigationMap());
#pragma warning restore CS0618
        var failures = new System.Collections.Generic.List<string>();
        var start = new PlanarPoint(_player.GlobalPosition.X, _player.GlobalPosition.Z);
        if (!GridPathfinder.TryFindDetour(_field.Grid, start, out var goal, out var plainPath))
        {
            failures.Add("plain detour was not found");
            goal = start;
            plainPath = System.Array.Empty<PlanarPoint>();
        }

        var before = _player.GlobalPosition;
        var accepted = _player.Navigation.TrySetDestination(new Vector3(goal.X, 0f, goal.Z));
        var agentPath = _player.Navigation.CurrentPath();
        if (!accepted)
        {
            failures.Add("agent rejected a walkable detour");
        }

        if (agentPath.Length < 2)
        {
            failures.Add($"agent path length {agentPath.Length}");
        }

        if (PathEntersBlocked(agentPath))
        {
            failures.Add("agent path enters a blocked rect");
            for (var i = 0; i < agentPath.Length && i < 12; i++)
            {
                GD.Print($"HARNESS path {i} {agentPath[i].X:0.00},{agentPath[i].Z:0.00}");
            }
        }

        _player.SimulateStep(0.05f);
        var moved = new Vector2(_player.GlobalPosition.X - before.X, _player.GlobalPosition.Z - before.Z).Length();
        var cap = _player.MoveSpeed * 0.05f;
        if (moved <= 0.001f)
        {
            failures.Add("player did not move along the path");
        }

        if (moved > cap + 0.02f)
        {
            failures.Add($"step {moved:0.000} exceeded cap {cap:0.000}");
        }

        var goalDistance = new PlanarPoint(_player.GlobalPosition.X, _player.GlobalPosition.Z).DistanceTo(goal);
        if (goalDistance < 1f)
        {
            failures.Add("player reached the destination in one step");
        }

        var parked = _player.GlobalPosition;
        _player.Navigation.Cancel();
        var outside = new Vector3(_field.Layout.HalfX + 5f, 0f, 0f);
        _input.SubmitPick(outside, false, false, _field.Layout);
        if (_player.GlobalPosition.DistanceTo(parked) > 0.001f)
        {
            failures.Add("invalid pick moved the player");
        }

        var blockedPoint = BlockedSample();
        var ray = RayDown(blockedPoint);
        _input.SubmitPick(blockedPoint, ray.HitBlocker || _field.Layout.IsInsideBlocked(new PlanarPoint(blockedPoint.X, blockedPoint.Z)), ray.HitGround, _field.Layout);
        if (_player.GlobalPosition.DistanceTo(parked) > 0.001f)
        {
            failures.Add("blocked pick moved the player");
        }

        var openPoint = _field.Grid.CellCenter(1, 1);
        var openRay = RayDown(new Vector3(openPoint.X, 0f, openPoint.Z));
        if (!openRay.HitGround)
        {
            failures.Add("downward ray missed the ground");
        }

        var sizeBefore = _camera.OrthographicSize;
        var yawBefore = _camera.YawDegrees;
        _camera.ZoomBy(1f);
        _camera.RotateQuarter(1);
        var cameraNode = _camera.GetNode<Camera3D>("Camera");
        if (_camera.OrthographicSize >= sizeBefore - 0.01f)
        {
            failures.Add("zoom did not reduce orthographic size");
        }

        if (Mathf.Abs(cameraNode.Size - _camera.OrthographicSize) > 0.01f)
        {
            failures.Add("camera node size was not applied");
        }

        var yawDelta = Mathf.PosMod(_camera.YawDegrees - yawBefore, 360f);
        if (Mathf.Abs(yawDelta - 90f) > 0.1f)
        {
            failures.Add($"yaw delta {yawDelta:0.00} was not 90");
        }

        if (_player.Animation.State != LocomotionState.Walking)
        {
            failures.Add($"animation state {_player.Animation.State}");
        }

        GD.Print($"HARNESS map={_field.Layout.Id} player=1");
        GD.Print($"HARNESS plain_points={plainPath.Count} agent_points={agentPath.Length} moved={moved:0.000} cap={cap:0.000}");
        GD.Print($"HARNESS ground_ray={openRay.HitGround} blocker_ray={ray.HitBlocker}");
        GD.Print($"HARNESS zoom {sizeBefore:0.00}->{_camera.OrthographicSize:0.00} yaw {yawBefore:0.00}->{_camera.YawDegrees:0.00}");
        GD.Print($"HARNESS animation={_player.Animation.AnimationName}");
        if (failures.Count == 0)
        {
            GD.Print("HARNESS_RESULT=pass");
            return 0;
        }

        foreach (var failure in failures)
        {
            GD.Print($"HARNESS_FAIL {failure}");
        }

        GD.Print("HARNESS_RESULT=fail");
        return 1;
    }

    private bool PathEntersBlocked(Vector3[] path)
    {
        for (var i = 0; i < path.Length; i++)
        {
            var point = new PlanarPoint(path[i].X, path[i].Z);
            if (_field.Layout.IsInsideBlocked(point, 0.2f))
            {
                return true;
            }

            if (i > 0)
            {
                var previous = new PlanarPoint(path[i - 1].X, path[i - 1].Z);
                if (_field.Layout.SegmentHitsBlocked(previous, point))
                {
                    return true;
                }
            }
        }

        return false;
    }

    private Vector3 BlockedSample()
    {
        var rect = _field.Layout.Blocked[0];
        return new Vector3((rect.MinX + rect.MaxX) * 0.5f, 0f, (rect.MinZ + rect.MaxZ) * 0.5f);
    }

    private (bool HitGround, bool HitBlocker) RayDown(Vector3 point)
    {
        var from = point + new Vector3(0f, 12f, 0f);
        var to = point + new Vector3(0f, -4f, 0f);
        var query = PhysicsRayQueryParameters3D.Create(from, to, 3);
        var hit = GetViewport().World3D.DirectSpaceState.IntersectRay(query);
        if (hit.Count == 0)
        {
            return (false, false);
        }

        var collider = hit["collider"].As<Node>();
        return (collider.IsInGroup("nav_ground"), collider.IsInGroup("nav_blocker"));
    }

    private static (int Column, int Row) CellOf(WalkGrid grid, PlanarPoint point)
    {
        _ = grid.TryWorldToCell(point, out var column, out var row);
        return (column, row);
    }
}
