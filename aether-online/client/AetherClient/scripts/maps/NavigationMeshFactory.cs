using Aether.ClientSim;
using Godot;

namespace Aether.Client.Maps;

public static class NavigationMeshFactory
{
    public static NavigationMesh Create(WalkGrid grid)
    {
        var mesh = new NavigationMesh();
        var vertices = new Vector3[(grid.Columns + 1) * (grid.Rows + 1)];
        var stride = grid.Columns + 1;
        for (var row = 0; row <= grid.Rows; row++)
        {
            for (var column = 0; column <= grid.Columns; column++)
            {
                vertices[(row * stride) + column] = new Vector3(
                    grid.OriginX + (column * grid.CellSize),
                    0f,
                    grid.OriginZ + (row * grid.CellSize));
            }
        }

        mesh.SetVertices(vertices);
        for (var row = 0; row < grid.Rows; row++)
        {
            for (var column = 0; column < grid.Columns; column++)
            {
                if (!grid.IsOpen(column, row))
                {
                    continue;
                }

                var i00 = (row * stride) + column;
                var i10 = i00 + 1;
                var i01 = i00 + stride;
                var i11 = i01 + 1;
                mesh.AddPolygon(new[] { i00, i10, i11, i01 });
            }
        }

        return mesh;
    }
}
