namespace Aether.ClientSim.Tests;

public class AnimationAndCameraTests
{
    [Fact]
    public void Animation_FollowsMovementDirection()
    {
        var logic = new CharacterAnimationLogic();
        logic.SetPlanarVelocity(1f, 0f);
        Assert.Equal(LocomotionState.Walking, logic.State);
        Assert.Equal(Facing8.East, logic.Facing);
        Assert.Equal("walk_east", logic.AnimationName);

        logic.SetPlanarVelocity(0f, 1f);
        Assert.Equal(Facing8.South, logic.Facing);

        logic.SetPlanarVelocity(-1f, -1f);
        Assert.Equal(Facing8.NorthWest, logic.Facing);

        logic.SetPlanarVelocity(0f, 0f);
        Assert.Equal(LocomotionState.Idle, logic.State);
        Assert.Equal(Facing8.NorthWest, logic.Facing);
        Assert.StartsWith("idle_", logic.AnimationName);
    }

    [Fact]
    public void AttackAndDeath_AreLocalAnimationStates()
    {
        var logic = new CharacterAnimationLogic();
        logic.SetPlanarVelocity(0f, 1f);
        logic.RequestAttack();
        Assert.Equal(LocomotionState.Attacking, logic.State);
        logic.SetPlanarVelocity(1f, 0f);
        Assert.Equal(LocomotionState.Attacking, logic.State);
        logic.Tick(0.3f);
        Assert.Equal(LocomotionState.Idle, logic.State);

        logic.RequestDeath();
        Assert.True(logic.IsDead);
        logic.SetPlanarVelocity(1f, 0f);
        logic.RequestAttack();
        Assert.Equal(LocomotionState.Death, logic.State);
        logic.Tick(1f);
        Assert.Equal(CharacterAnimationLogic.DeathFrames - 1, logic.Frame);
        logic.Revive();
        Assert.Equal(LocomotionState.Idle, logic.State);
    }

    [Fact]
    public void ZoomAndQuarterTurns_ChangeCameraState()
    {
        var rig = new IsometricCameraRig();
        var initialSize = rig.OrthographicSize;
        var initialYaw = rig.YawDegrees;
        rig.ZoomBy(1f);
        Assert.True(rig.OrthographicSize < initialSize);
        rig.ZoomBy(-1f);
        Assert.InRange(rig.OrthographicSize, initialSize - 0.05f, initialSize + 0.05f);
        rig.ZoomBy(40f);
        Assert.Equal(rig.MinOrthographicSize, rig.OrthographicSize);
        rig.ZoomBy(-40f);
        Assert.Equal(rig.MaxOrthographicSize, rig.OrthographicSize);

        rig.RotateQuarter(1);
        Assert.Equal(Normalize(initialYaw + 90f), rig.YawDegrees);
        rig.RotateQuarter(3);
        Assert.Equal(initialYaw, rig.YawDegrees);
        Assert.True(rig.FarClip > rig.Distance);
    }

    [Fact]
    public void Follow_MovesTowardTheTarget_WithoutSnapping()
    {
        var rig = new IsometricCameraRig();
        rig.SnapTo(0f, 0f, 0f);
        rig.Follow(10f, 0f, 0f, 0.05f);
        Assert.InRange(rig.FocusX, 0.1f, 9f);
    }

    [Fact]
    public void DirectMove_UsesCameraYaw()
    {
        var rig = new IsometricCameraRig(yawDegrees: 0f);
        var forward = rig.CameraRelativeMove(0f, 1f);
        Assert.InRange(forward.X, -0.01f, 0.01f);
        Assert.InRange(forward.Z, -1.01f, -0.99f);
    }

    [Fact]
    public void ClientScene_IsTheField_AndContainsOnePlayer()
    {
        var root = RepoRoot();
        var project = File.ReadAllText(Path.Combine(root, "client", "AetherClient", "project.godot"));
        var scene = File.ReadAllText(Path.Combine(root, "client", "AetherClient", "scenes", "maps", "VerdantTestField.tscn"));
        var server = File.ReadAllText(Path.Combine(root, "server", "AetherServer", "AetherServer.csproj"));
        Assert.Contains("run/main_scene=\"res://scenes/maps/VerdantTestField.tscn\"", project, StringComparison.Ordinal);
        Assert.Contains("name=\"Player\"", scene, StringComparison.Ordinal);
        Assert.Contains("PlayerController.cs", scene, StringComparison.Ordinal);
        Assert.Contains("PlayerVisual.cs", scene, StringComparison.Ordinal);
        Assert.Contains("CharacterAnimationController.cs", scene, StringComparison.Ordinal);
        Assert.Contains("IsometricCameraController.cs", scene, StringComparison.Ordinal);
        Assert.Contains("ClickToMoveInput.cs", scene, StringComparison.Ordinal);
        Assert.Contains("LocalNavigationController.cs", scene, StringComparison.Ordinal);
        Assert.Contains("DebugOverlay.cs", scene, StringComparison.Ordinal);
        Assert.Contains("NavigationAgent3D", scene, StringComparison.Ordinal);
        Assert.DoesNotContain("Aether.ClientSim", server, StringComparison.Ordinal);
        Assert.DoesNotContain("AetherClient", server, StringComparison.Ordinal);
    }

    private static float Normalize(float degrees)
    {
        var wrapped = degrees % 360f;
        return wrapped < 0f ? wrapped + 360f : wrapped;
    }

    private static string RepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "AetherOnline.sln")))
            {
                return dir.FullName;
            }

            dir = dir.Parent;
        }

        throw new InvalidOperationException("Repository root was not found.");
    }
}
