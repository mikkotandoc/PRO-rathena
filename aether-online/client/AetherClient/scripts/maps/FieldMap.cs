using Aether.ClientSim;
using Godot;

namespace Aether.Client.Maps;

public partial class FieldMap : Node3D
{
    public const string LayoutPath = "res://content/maps/verdant-test-field.json";

    public MapLayout Layout { get; private set; } = null!;

    public WalkGrid Grid { get; private set; } = null!;

    public NavigationRegion3D Region { get; private set; } = null!;

    public override void _Ready()
    {
        using var file = Godot.FileAccess.Open(LayoutPath, Godot.FileAccess.ModeFlags.Read);
        if (file is null)
        {
            throw new System.IO.FileNotFoundException("Map layout is missing.", LayoutPath);
        }

        Layout = MapLayout.Parse(file.GetAsText());
        Grid = WalkGrid.FromLayout(Layout);
        AddToGroup("field_map");
        BuildGround();
        BuildPaths();
        BuildBlockedMarkers();
        BuildProps();
        Region = new NavigationRegion3D { Name = "Navigation" };
        Region.AddToGroup("navigation_region");
        AddChild(Region);
        Region.NavigationMesh = NavigationMeshFactory.Create(Grid);
#pragma warning disable CS0618
        NavigationServer3D.MapForceUpdate(Region.GetNavigationMap());
#pragma warning restore CS0618
    }

    private void BuildGround()
    {
        var body = new StaticBody3D { Name = "Ground", CollisionLayer = 1, CollisionMask = 0 };
        body.AddToGroup("nav_ground");
        var shape = new CollisionShape3D
        {
            Shape = new BoxShape3D { Size = new Vector3(Layout.SizeX, 1f, Layout.SizeZ) },
            Position = new Vector3(0f, -0.5f, 0f),
        };
        body.AddChild(shape);
        body.AddChild(new MeshInstance3D
        {
            Name = "GroundMesh",
            Mesh = new BoxMesh { Size = new Vector3(Layout.SizeX, 0.2f, Layout.SizeZ) },
            Position = new Vector3(0f, -0.1f, 0f),
            MaterialOverride = new StandardMaterial3D
            {
                AlbedoColor = new Color(0.29f, 0.46f, 0.28f),
                Roughness = 1f,
            },
        });
        AddChild(body);
    }

    private void BuildPaths()
    {
        foreach (var strip in Layout.Paths)
        {
            var sizeX = strip.MaxX - strip.MinX;
            var sizeZ = strip.MaxZ - strip.MinZ;
            AddChild(new MeshInstance3D
            {
                Name = strip.Id,
                Mesh = new BoxMesh { Size = new Vector3(sizeX, 0.04f, sizeZ) },
                Position = new Vector3((strip.MinX + strip.MaxX) * 0.5f, 0.02f, (strip.MinZ + strip.MaxZ) * 0.5f),
                MaterialOverride = new StandardMaterial3D
                {
                    AlbedoColor = new Color(0.55f, 0.46f, 0.28f),
                    Roughness = 1f,
                },
            });
        }
    }

    private void BuildBlockedMarkers()
    {
        foreach (var rect in Layout.Blocked)
        {
            if (rect.Id == "prop")
            {
                continue;
            }

            var sizeX = rect.MaxX - rect.MinX;
            var sizeZ = rect.MaxZ - rect.MinZ;
            var body = new StaticBody3D
            {
                Name = rect.Id,
                CollisionLayer = 2,
                CollisionMask = 0,
                Position = new Vector3((rect.MinX + rect.MaxX) * 0.5f, 0f, (rect.MinZ + rect.MaxZ) * 0.5f),
            };
            body.AddToGroup("nav_blocker");
            body.AddChild(new CollisionShape3D
            {
                Shape = new BoxShape3D { Size = new Vector3(sizeX, 2f, sizeZ) },
                Position = new Vector3(0f, 1f, 0f),
            });
            body.AddChild(new MeshInstance3D
            {
                Mesh = new BoxMesh { Size = new Vector3(sizeX, 0.06f, sizeZ) },
                Position = new Vector3(0f, 0.04f, 0f),
                MaterialOverride = new StandardMaterial3D
                {
                    AlbedoColor = new Color(0.16f, 0.2f, 0.14f, 0.85f),
                    Transparency = BaseMaterial3D.TransparencyEnum.Alpha,
                    Roughness = 1f,
                },
            });
            AddChild(body);
        }
    }

    private void BuildProps()
    {
        var props = new Node3D { Name = "Props" };
        AddChild(props);
        foreach (var prop in Layout.Props)
        {
            props.AddChild(PropFactory.Create(prop));
        }
    }
}
