namespace Aether.ClientSim;

public readonly record struct PlanarPoint(float X, float Z)
{
    public float DistanceTo(PlanarPoint other)
    {
        var dx = other.X - X;
        var dz = other.Z - Z;
        return MathF.Sqrt((dx * dx) + (dz * dz));
    }
}

public static class PlanarStep
{
    public static PlanarPoint MoveToward(PlanarPoint from, PlanarPoint to, float maxDistance)
    {
        if (maxDistance < 0f)
        {
            throw new ArgumentOutOfRangeException(nameof(maxDistance));
        }

        var dx = to.X - from.X;
        var dz = to.Z - from.Z;
        var length = MathF.Sqrt((dx * dx) + (dz * dz));
        if (length <= 0.0001f || length <= maxDistance)
        {
            return length <= maxDistance ? to : from;
        }

        var scale = maxDistance / length;
        return new PlanarPoint(from.X + (dx * scale), from.Z + (dz * scale));
    }
}
