namespace Aether.ClientSim.Tests;

public class MovementTests
{
    [Fact]
    public void WalkableClick_YieldsAPath_AndMovementStaysOnThePath()
    {
        var layout = new MapLayout(
            "map.test",
            "Test",
            8f,
            8f,
            8,
            new PlanarPoint(-3f, 0f),
            new[] { new BlockRect("wall", -0.5f, 0.5f, -4f, 1f) },
            Array.Empty<PathStrip>(),
            Array.Empty<MapProp>());
        var grid = WalkGrid.FromLayout(layout);
        var start = new PlanarPoint(-3f, 0f);
        var goal = new PlanarPoint(3f, 0f);
        Assert.True(layout.SegmentHitsBlocked(start, goal));

        var follower = new PathFollower(start);
        Assert.True(follower.TrySetDestination(grid, goal));
        Assert.True(follower.Waypoints.Count >= 2);
        Assert.False(GridPathfinder.PathHitsBlocked(layout, follower.Waypoints));

        var before = follower.Position;
        var moved = follower.Step(6f, 0.05f);
        Assert.InRange(moved, 0.01f, 0.32f);
        Assert.True(follower.Position.DistanceTo(goal) > 1f);
        Assert.True(follower.Position.DistanceTo(before) <= 0.32f);
    }

    [Fact]
    public void InvalidTerrain_DoesNotMoveTheFollower()
    {
        var layout = Verdant();
        var grid = WalkGrid.FromLayout(layout);
        var follower = new PathFollower(layout.PlayerStart);
        var outside = new PlanarPoint(layout.HalfX + 5f, 0f);
        var before = follower.Position;
        Assert.False(follower.TrySetDestination(grid, outside));
        Assert.Equal("rejected", follower.Status);
        Assert.Equal(before, follower.Position);
        Assert.Equal(0f, follower.Step(6f, 0.05f));

        var blocked = new PlanarPoint(0f, 0f);
        Assert.False(layout.IsWalkable(blocked));
        Assert.False(follower.TrySetDestination(grid, blocked));
        Assert.Equal(before, follower.Position);
    }

    [Fact]
    public void VerdantField_RoutesAroundTheGrove()
    {
        var layout = Verdant();
        var grid = WalkGrid.FromLayout(layout);
        Assert.Equal(40f, layout.SizeX);
        Assert.Equal(40f, layout.SizeZ);
        Assert.True(GridPathfinder.TryFindDetour(grid, layout.PlayerStart, out var goal, out var path));
        Assert.True(layout.SegmentHitsBlocked(layout.PlayerStart, goal));
        Assert.False(GridPathfinder.PathHitsBlocked(layout, path));
        Assert.True(layout.IsWalkable(goal));
    }

    [Fact]
    public void MapSize_IsReadFromTheDocument_AndCopiesMatch()
    {
        var repo = RepoRoot();
        var data = File.ReadAllText(Path.Combine(repo, "data", "maps", "verdant-test-field.json"));
        var client = File.ReadAllText(Path.Combine(repo, "client", "AetherClient", "content", "maps", "verdant-test-field.json"));
        Assert.Equal(client, data);
        var layout = MapLayout.Parse(client);
        Assert.Equal("map.verdant-test-field", layout.Id);
        Assert.Equal(40f, layout.SizeX);
        Assert.Equal(20, layout.CellsAlongShortSide);
        var grid = WalkGrid.FromLayout(layout);
        Assert.Equal(layout.SizeX / layout.CellsAlongShortSide, grid.CellSize);
    }

    private static MapLayout Verdant()
    {
        var path = Path.Combine(RepoRoot(), "data", "maps", "verdant-test-field.json");
        return MapLayout.Parse(File.ReadAllText(path));
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
