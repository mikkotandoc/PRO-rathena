namespace Aether.ClientSim;

public sealed class WalkGrid
{
    private readonly bool[] _open;

    private WalkGrid(MapLayout layout, float originX, float originZ, float cellSize, int columns, int rows, bool[] open)
    {
        Layout = layout;
        OriginX = originX;
        OriginZ = originZ;
        CellSize = cellSize;
        Columns = columns;
        Rows = rows;
        _open = open;
    }

    public MapLayout Layout { get; }

    public float OriginX { get; }

    public float OriginZ { get; }

    public float CellSize { get; }

    public int Columns { get; }

    public int Rows { get; }

    public static WalkGrid FromLayout(MapLayout layout)
    {
        var shortSide = MathF.Min(layout.SizeX, layout.SizeZ);
        var cellSize = shortSide / layout.CellsAlongShortSide;
        var columns = Math.Max(1, (int)MathF.Round(layout.SizeX / cellSize));
        var rows = Math.Max(1, (int)MathF.Round(layout.SizeZ / cellSize));
        var originX = -layout.HalfX;
        var originZ = -layout.HalfZ;
        var open = new bool[columns * rows];
        for (var row = 0; row < rows; row++)
        {
            for (var col = 0; col < columns; col++)
            {
                var minX = originX + (col * cellSize);
                var minZ = originZ + (row * cellSize);
                var blocked = false;
                foreach (var rect in layout.Blocked)
                {
                    var clearance = MathF.Min(0.75f, cellSize * 0.5f);
                    var grown = new BlockRect(rect.Id, rect.MinX - clearance, rect.MaxX + clearance, rect.MinZ - clearance, rect.MaxZ + clearance);
                    if (grown.IntersectsCell(minX, minZ, minX + cellSize, minZ + cellSize))
                    {
                        blocked = true;
                        break;
                    }
                }

                open[(row * columns) + col] = !blocked;
            }
        }

        return new WalkGrid(layout, originX, originZ, cellSize, columns, rows, open);
    }

    public bool IsOpen(int column, int row)
    {
        if (column < 0 || row < 0 || column >= Columns || row >= Rows)
        {
            return false;
        }

        return _open[(row * Columns) + column];
    }

    public bool TryWorldToCell(PlanarPoint point, out int column, out int row)
    {
        column = (int)MathF.Floor(((point.X - OriginX) / CellSize) + 0.0001f);
        row = (int)MathF.Floor(((point.Z - OriginZ) / CellSize) + 0.0001f);
        return IsOpen(column, row) || (column >= 0 && row >= 0 && column < Columns && row < Rows);
    }

    public PlanarPoint CellCenter(int column, int row)
    {
        return new PlanarPoint(
            OriginX + ((column + 0.5f) * CellSize),
            OriginZ + ((row + 0.5f) * CellSize));
    }

    public bool IsWalkable(PlanarPoint point)
    {
        if (!Layout.Contains(point))
        {
            return false;
        }

        if (!TryWorldToCell(point, out var column, out var row))
        {
            return false;
        }

        return IsOpen(column, row);
    }
}
