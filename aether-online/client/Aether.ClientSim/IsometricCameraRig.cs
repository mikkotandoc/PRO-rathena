namespace Aether.ClientSim;

public sealed class IsometricCameraRig
{
    public IsometricCameraRig(float orthographicSize = 12f, float yawDegrees = 45f)
    {
        OrthographicSize = orthographicSize;
        YawDegrees = Normalize(yawDegrees);
    }

    public float PitchDegrees { get; } = -35.264f;

    public float Distance { get; } = 22f;

    public float MinOrthographicSize { get; } = 5f;

    public float MaxOrthographicSize { get; } = 28f;

    public float OrthographicSize { get; private set; }

    public float YawDegrees { get; private set; }

    public float FocusX { get; private set; }

    public float FocusY { get; private set; }

    public float FocusZ { get; private set; }

    public float FarClip => Distance * 8f;

    public void ZoomBy(float notches)
    {
        var factor = MathF.Pow(0.9f, notches);
        OrthographicSize = Math.Clamp(OrthographicSize * factor, MinOrthographicSize, MaxOrthographicSize);
    }

    public void RotateQuarter(int turns)
    {
        YawDegrees = Normalize(YawDegrees + (90f * turns));
    }

    public void SnapTo(float x, float y, float z)
    {
        FocusX = x;
        FocusY = y;
        FocusZ = z;
    }

    public void Follow(float x, float y, float z, float delta, float sharpness = 8f)
    {
        var blend = 1f - MathF.Exp(-sharpness * MathF.Max(0f, delta));
        FocusX += (x - FocusX) * blend;
        FocusY += (y - FocusY) * blend;
        FocusZ += (z - FocusZ) * blend;
    }

    public PlanarPoint CameraRelativeMove(float strafe, float forward)
    {
        var yaw = YawDegrees * (MathF.PI / 180f);
        var sin = MathF.Sin(yaw);
        var cos = MathF.Cos(yaw);
        var forwardX = -sin;
        var forwardZ = -cos;
        var rightX = cos;
        var rightZ = -sin;
        return new PlanarPoint((rightX * strafe) + (forwardX * forward), (rightZ * strafe) + (forwardZ * forward));
    }

    private static float Normalize(float degrees)
    {
        var wrapped = degrees % 360f;
        return wrapped < 0f ? wrapped + 360f : wrapped;
    }
}
