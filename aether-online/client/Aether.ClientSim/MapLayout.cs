using System.Text.Json;

namespace Aether.ClientSim;

public sealed record BlockRect(string Id, float MinX, float MaxX, float MinZ, float MaxZ)
{
    public bool Contains(PlanarPoint point, float inset = 0f)
    {
        return point.X > MinX + inset
            && point.X < MaxX - inset
            && point.Z > MinZ + inset
            && point.Z < MaxZ - inset;
    }

    public bool IntersectsCell(float cellMinX, float cellMinZ, float cellMaxX, float cellMaxZ)
    {
        return cellMinX < MaxX && cellMaxX > MinX && cellMinZ < MaxZ && cellMaxZ > MinZ;
    }
}

public sealed record PathStrip(string Id, float MinX, float MaxX, float MinZ, float MaxZ);

public sealed record MapProp(string Kind, float X, float Z, float BlockHalfExtent);

public sealed class MapLayout
{
    public MapLayout(
        string id,
        string displayName,
        float sizeX,
        float sizeZ,
        int cellsAlongShortSide,
        PlanarPoint playerStart,
        IReadOnlyList<BlockRect> blocked,
        IReadOnlyList<PathStrip> paths,
        IReadOnlyList<MapProp> props)
    {
        if (sizeX <= 0f || sizeZ <= 0f)
        {
            throw new ArgumentOutOfRangeException(nameof(sizeX));
        }

        if (cellsAlongShortSide < 2)
        {
            throw new ArgumentOutOfRangeException(nameof(cellsAlongShortSide));
        }

        Id = id;
        DisplayName = displayName;
        SizeX = sizeX;
        SizeZ = sizeZ;
        CellsAlongShortSide = cellsAlongShortSide;
        PlayerStart = playerStart;
        Blocked = blocked;
        Paths = paths;
        Props = props;
    }

    public string Id { get; }

    public string DisplayName { get; }

    public float SizeX { get; }

    public float SizeZ { get; }

    public int CellsAlongShortSide { get; }

    public PlanarPoint PlayerStart { get; }

    public IReadOnlyList<BlockRect> Blocked { get; }

    public IReadOnlyList<PathStrip> Paths { get; }

    public IReadOnlyList<MapProp> Props { get; }

    public float HalfX => SizeX * 0.5f;

    public float HalfZ => SizeZ * 0.5f;

    public bool Contains(PlanarPoint point)
    {
        return point.X >= -HalfX && point.X <= HalfX && point.Z >= -HalfZ && point.Z <= HalfZ;
    }

    public bool IsInsideBlocked(PlanarPoint point, float inset = 0f)
    {
        foreach (var rect in Blocked)
        {
            if (rect.Contains(point, inset))
            {
                return true;
            }
        }

        return false;
    }

    public bool IsWalkable(PlanarPoint point)
    {
        return Contains(point) && !IsInsideBlocked(point);
    }

    public bool SegmentHitsBlocked(PlanarPoint from, PlanarPoint to)
    {
        foreach (var rect in Blocked)
        {
            var interior = new BlockRect(rect.Id, rect.MinX + 0.2f, rect.MaxX - 0.2f, rect.MinZ + 0.2f, rect.MaxZ - 0.2f);
            if (interior.MaxX <= interior.MinX || interior.MaxZ <= interior.MinZ)
            {
                continue;
            }

            if (SegmentIntersectsRect(from, to, interior))
            {
                return true;
            }
        }

        return false;
    }

    public static bool SegmentIntersectsRect(PlanarPoint from, PlanarPoint to, BlockRect rect)
    {
        var dx = to.X - from.X;
        var dz = to.Z - from.Z;
        var t0 = 0f;
        var t1 = 1f;
        if (!Clip(-dx, from.X - rect.MinX, ref t0, ref t1))
        {
            return false;
        }

        if (!Clip(dx, rect.MaxX - from.X, ref t0, ref t1))
        {
            return false;
        }

        if (!Clip(-dz, from.Z - rect.MinZ, ref t0, ref t1))
        {
            return false;
        }

        if (!Clip(dz, rect.MaxZ - from.Z, ref t0, ref t1))
        {
            return false;
        }

        return true;
    }

    public static MapLayout Parse(string json)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        var size = root.GetProperty("size");
        var start = root.GetProperty("playerStart");
        var blocked = new List<BlockRect>();
        foreach (var rect in root.GetProperty("blocked").EnumerateArray())
        {
            blocked.Add(new BlockRect(
                rect.GetProperty("id").GetString() ?? "blocked",
                rect.GetProperty("minX").GetSingle(),
                rect.GetProperty("maxX").GetSingle(),
                rect.GetProperty("minZ").GetSingle(),
                rect.GetProperty("maxZ").GetSingle()));
        }

        var paths = new List<PathStrip>();
        if (root.TryGetProperty("paths", out var pathArray))
        {
            foreach (var strip in pathArray.EnumerateArray())
            {
                paths.Add(new PathStrip(
                    strip.GetProperty("id").GetString() ?? "path",
                    strip.GetProperty("minX").GetSingle(),
                    strip.GetProperty("maxX").GetSingle(),
                    strip.GetProperty("minZ").GetSingle(),
                    strip.GetProperty("maxZ").GetSingle()));
            }
        }

        var props = new List<MapProp>();
        if (root.TryGetProperty("props", out var propArray))
        {
            foreach (var prop in propArray.EnumerateArray())
            {
                var block = prop.TryGetProperty("blockHalfExtent", out var half) ? half.GetSingle() : 0f;
                props.Add(new MapProp(
                    prop.GetProperty("kind").GetString() ?? "prop",
                    prop.GetProperty("x").GetSingle(),
                    prop.GetProperty("z").GetSingle(),
                    block));
                if (block > 0f)
                {
                    var x = prop.GetProperty("x").GetSingle();
                    var z = prop.GetProperty("z").GetSingle();
                    blocked.Add(new BlockRect(
                        "prop",
                        x - block,
                        x + block,
                        z - block,
                        z + block));
                }
            }
        }

        return new MapLayout(
            root.GetProperty("id").GetString() ?? "map",
            root.GetProperty("displayName").GetString() ?? "Map",
            size.GetProperty("x").GetSingle(),
            size.GetProperty("z").GetSingle(),
            root.GetProperty("cellsAlongShortSide").GetInt32(),
            new PlanarPoint(start.GetProperty("x").GetSingle(), start.GetProperty("z").GetSingle()),
            blocked,
            paths,
            props);
    }

    private static bool Clip(float edge, float distance, ref float t0, ref float t1)
    {
        if (MathF.Abs(edge) < 0.0000001f)
        {
            return distance >= 0f;
        }

        var t = distance / edge;
        if (edge < 0f)
        {
            if (t > t1)
            {
                return false;
            }

            if (t > t0)
            {
                t0 = t;
            }
        }
        else
        {
            if (t < t0)
            {
                return false;
            }

            if (t < t1)
            {
                t1 = t;
            }
        }

        return true;
    }
}
