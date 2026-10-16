using Aether.Client.Maps;
using Aether.ClientSim;
using Godot;

namespace Aether.Client.Input;

public partial class ClickToMoveInput : Node
{
    [Signal]
    public delegate void DestinationPickedEventHandler(Vector3 worldPosition);

    [Signal]
    public delegate void DestinationRejectedEventHandler(Vector3 worldPosition);

    [Signal]
    public delegate void DirectMoveChangedEventHandler(Vector2 cameraRelative);

    [Signal]
    public delegate void AttackPressedEventHandler();

    [Signal]
    public delegate void DeathPressedEventHandler();

    [Signal]
    public delegate void RevivePressedEventHandler();

    [Signal]
    public delegate void ZoomRequestedEventHandler(float notches);

    [Signal]
    public delegate void RotateRequestedEventHandler(int turns);

    public Vector2 DirectMove { get; private set; }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton mouse && mouse.Pressed)
        {
            if (mouse.ButtonIndex == MouseButton.Left)
            {
                PickUnderCursor(mouse.Position);
                GetViewport().SetInputAsHandled();
            }
            else if (mouse.ButtonIndex == MouseButton.WheelUp)
            {
                EmitSignal(SignalName.ZoomRequested, 1f);
            }
            else if (mouse.ButtonIndex == MouseButton.WheelDown)
            {
                EmitSignal(SignalName.ZoomRequested, -1f);
            }

            return;
        }

        if (@event is not InputEventKey key || !key.Pressed || key.Echo)
        {
            return;
        }

        switch (key.Keycode)
        {
            case Key.F:
                EmitSignal(SignalName.AttackPressed);
                break;
            case Key.G:
                EmitSignal(SignalName.DeathPressed);
                break;
            case Key.T:
                EmitSignal(SignalName.RevivePressed);
                break;
            case Key.Q:
                EmitSignal(SignalName.RotateRequested, -1);
                break;
            case Key.E:
                EmitSignal(SignalName.RotateRequested, 1);
                break;
        }
    }

    public override void _Process(double delta)
    {
        var right = ReadAxis(Key.D, Key.A);
        var forward = ReadAxis(Key.W, Key.S);
        var next = new Vector2(right, forward);
        if (next != DirectMove)
        {
            DirectMove = next;
            EmitSignal(SignalName.DirectMoveChanged, DirectMove);
        }
    }

    public void PickUnderCursor(Vector2 screenPosition)
    {
        var camera = GetViewport().GetCamera3D();
        var field = GetTree().GetFirstNodeInGroup("field_map") as FieldMap;
        if (camera is null || field is null)
        {
            return;
        }

        var origin = camera.ProjectRayOrigin(screenPosition);
        var end = origin + (camera.ProjectRayNormal(screenPosition) * camera.Far);
        var query = PhysicsRayQueryParameters3D.Create(origin, end, 3);
        var hit = GetViewport().World3D.DirectSpaceState.IntersectRay(query);
        if (hit.Count == 0)
        {
            EmitSignal(SignalName.DestinationRejected, origin);
            return;
        }

        var point = hit["position"].AsVector3();
        var collider = hit["collider"].As<Node>();
        SubmitPick(point, collider.IsInGroup("nav_blocker"), collider.IsInGroup("nav_ground"), field.Layout);
    }

    public void SubmitPick(Vector3 point, bool hitBlocker, bool hitGround, MapLayout layout)
    {
        var planar = new PlanarPoint(point.X, point.Z);
        var walkable = !hitBlocker && hitGround && WalkGrid.FromLayout(layout).IsWalkable(planar);
        if (!walkable)
        {
            EmitSignal(SignalName.DestinationRejected, point);
            return;
        }

        EmitSignal(SignalName.DestinationPicked, new Vector3(point.X, 0f, point.Z));
    }

    private static float ReadAxis(Key positive, Key negative)
    {
        var value = 0f;
        if (Godot.Input.IsKeyPressed(positive))
        {
            value += 1f;
        }

        if (Godot.Input.IsKeyPressed(negative))
        {
            value -= 1f;
        }

        return value;
    }
}
