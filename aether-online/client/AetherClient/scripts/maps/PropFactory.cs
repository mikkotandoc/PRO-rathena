using Aether.ClientSim;
using Godot;

namespace Aether.Client.Maps;

public static class PropFactory
{
    public static Node3D Create(MapProp prop)
    {
        var root = new Node3D
        {
            Name = prop.Kind,
            Position = new Vector3(prop.X, 0f, prop.Z),
        };

        switch (prop.Kind)
        {
            case "tree":
                root.AddChild(Mesh("Trunk", new CylinderMesh { TopRadius = 0.18f, BottomRadius = 0.24f, Height = 1.1f }, new Vector3(0f, 0.55f, 0f), new Color(0.38f, 0.26f, 0.16f)));
                root.AddChild(Mesh("Canopy", new SphereMesh { Radius = 0.85f, Height = 1.5f }, new Vector3(0f, 1.55f, 0f), new Color(0.22f, 0.48f, 0.26f)));
                break;
            case "rock":
                root.AddChild(Mesh("Stone", new SphereMesh { Radius = 0.55f, Height = 0.8f }, new Vector3(0f, 0.28f, 0f), new Color(0.45f, 0.46f, 0.48f)));
                break;
            default:
                root.AddChild(Mesh("Walls", new BoxMesh { Size = new Vector3(2.4f, 1.6f, 2.2f) }, new Vector3(0f, 0.8f, 0f), new Color(0.62f, 0.58f, 0.5f)));
                root.AddChild(Mesh("Roof", new BoxMesh { Size = new Vector3(2.8f, 0.35f, 2.6f) }, new Vector3(0f, 1.75f, 0f), new Color(0.45f, 0.28f, 0.22f)));
                break;
        }

        return root;
    }

    private static MeshInstance3D Mesh(string name, Mesh mesh, Vector3 position, Color color)
    {
        return new MeshInstance3D
        {
            Name = name,
            Mesh = mesh,
            Position = position,
            MaterialOverride = new StandardMaterial3D
            {
                AlbedoColor = color,
                Roughness = 0.92f,
            },
        };
    }
}
