namespace Aether.ClientSim;

public enum LocomotionState
{
    Idle,
    Walking,
    Attacking,
    Death,
}

public enum Facing8
{
    South = 0,
    SouthEast = 1,
    East = 2,
    NorthEast = 3,
    North = 4,
    NorthWest = 5,
    West = 6,
    SouthWest = 7,
}

public sealed class CharacterAnimationLogic
{
    public const int FrameSize = 64;
    public const int DirectionCount = 8;
    public const int IdleFrames = 2;
    public const int WalkFrames = 4;
    public const int AttackFrames = 2;
    public const int DeathFrames = 2;
    public const float FramesPerSecond = 8f;

    public LocomotionState State { get; private set; } = LocomotionState.Idle;

    public Facing8 Facing { get; private set; } = Facing8.South;

    private float _frameBank;

    public int Frame { get; private set; }

    public bool IsDead => State == LocomotionState.Death;

    public string AnimationName => $"{StateName(State)}_{FacingName(Facing)}";

    public static int RowCount => IdleFrames + WalkFrames + AttackFrames + DeathFrames;

    public static int RowFor(LocomotionState state, int frame)
    {
        var first = state switch
        {
            LocomotionState.Idle => 0,
            LocomotionState.Walking => IdleFrames,
            LocomotionState.Attacking => IdleFrames + WalkFrames,
            LocomotionState.Death => IdleFrames + WalkFrames + AttackFrames,
            _ => 0,
        };
        return first + frame;
    }

    public static int FrameCount(LocomotionState state)
    {
        return state switch
        {
            LocomotionState.Idle => IdleFrames,
            LocomotionState.Walking => WalkFrames,
            LocomotionState.Attacking => AttackFrames,
            LocomotionState.Death => DeathFrames,
            _ => 1,
        };
    }

    public static Facing8 FacingFromVelocity(float x, float z)
    {
        var octant = (int)MathF.Round(MathF.Atan2(x, z) / (MathF.PI / 4f));
        var index = octant % DirectionCount;
        if (index < 0)
        {
            index += DirectionCount;
        }

        return (Facing8)index;
    }

    public void SetPlanarVelocity(float x, float z, float threshold = 0.05f)
    {
        if (State is LocomotionState.Death or LocomotionState.Attacking)
        {
            return;
        }

        var moving = MathF.Sqrt((x * x) + (z * z)) > threshold;
        if (moving)
        {
            if (State != LocomotionState.Walking)
            {
                Frame = 0;
            }

            State = LocomotionState.Walking;
            Facing = FacingFromVelocity(x, z);
            return;
        }

        if (State == LocomotionState.Walking)
        {
            State = LocomotionState.Idle;
            Frame = 0;
        }
    }

    public void RequestAttack()
    {
        if (State == LocomotionState.Death)
        {
            return;
        }

        State = LocomotionState.Attacking;
        Frame = 0;
        _frameBank = 0f;
    }

    public void RequestDeath()
    {
        State = LocomotionState.Death;
        Frame = 0;
        _frameBank = 0f;
    }

    public void Revive()
    {
        State = LocomotionState.Idle;
        Frame = 0;
        _frameBank = 0f;
    }

    public void Tick(float delta)
    {
        if (delta <= 0f)
        {
            return;
        }

        _frameBank += delta;
        var step = 1f / FramesPerSecond;
        while (_frameBank >= step)
        {
            _frameBank -= step;
            AdvanceFrame();
        }
    }

    private void AdvanceFrame()
    {
        var count = FrameCount(State);
        if (State == LocomotionState.Death)
        {
            Frame = Math.Min(count - 1, Frame + 1);
            return;
        }

        if (State == LocomotionState.Attacking)
        {
            Frame++;
            if (Frame >= count)
            {
                State = LocomotionState.Idle;
                Frame = 0;
            }

            return;
        }

        Frame = (Frame + 1) % count;
    }

    public static string StateName(LocomotionState state)
    {
        return state switch
        {
            LocomotionState.Idle => "idle",
            LocomotionState.Walking => "walk",
            LocomotionState.Attacking => "attack",
            LocomotionState.Death => "death",
            _ => "idle",
        };
    }

    public static string FacingName(Facing8 facing)
    {
        return facing switch
        {
            Facing8.South => "south",
            Facing8.SouthEast => "southeast",
            Facing8.East => "east",
            Facing8.NorthEast => "northeast",
            Facing8.North => "north",
            Facing8.NorthWest => "northwest",
            Facing8.West => "west",
            Facing8.SouthWest => "southwest",
            _ => "south",
        };
    }
}
