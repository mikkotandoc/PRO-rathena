using Aether.ClientSim;
using Godot;

namespace Aether.Client.Player;

public partial class PlayerVisual : AnimatedSprite3D
{
    public const string SpritePath = "res://assets/sprites/placeholder-traveler.png";

    public override void _Ready()
    {
        var texture = GD.Load<Texture2D>(SpritePath);
        if (texture is null)
        {
            GD.PushError($"Missing placeholder sprite at {SpritePath}.");
            return;
        }
        var frames = new SpriteFrames();
        frames.RemoveAnimation("default");
        foreach (LocomotionState state in System.Enum.GetValues<LocomotionState>())
        {
            var count = CharacterAnimationLogic.FrameCount(state);
            foreach (Facing8 facing in System.Enum.GetValues<Facing8>())
            {
                var name = $"{CharacterAnimationLogic.StateName(state)}_{CharacterAnimationLogic.FacingName(facing)}";
                frames.AddAnimation(name);
                frames.SetAnimationLoop(name, false);
                for (var frame = 0; frame < count; frame++)
                {
                    var atlas = new AtlasTexture
                    {
                        Atlas = texture,
                        Region = new Rect2(
                            (int)facing * CharacterAnimationLogic.FrameSize,
                            CharacterAnimationLogic.RowFor(state, frame) * CharacterAnimationLogic.FrameSize,
                            CharacterAnimationLogic.FrameSize,
                            CharacterAnimationLogic.FrameSize),
                    };
                    frames.AddFrame(name, atlas);
                }
            }
        }

        SpriteFrames = frames;
        Animation = "idle_south";
        Frame = 0;
        Centered = true;
        PixelSize = 0.025f;
        Billboard = BaseMaterial3D.BillboardModeEnum.FixedY;
        Transparent = true;
        AlphaCut = AlphaCutMode.Disabled;
        TextureFilter = BaseMaterial3D.TextureFilterEnum.Nearest;
        DoubleSided = true;
        Position = new Vector3(0f, PixelSize * CharacterAnimationLogic.FrameSize * 0.5f, 0f);
        var shadow = GetNode<MeshInstance3D>("../Shadow");
        shadow.Mesh = new CylinderMesh { TopRadius = 0.32f, BottomRadius = 0.32f, Height = 0.04f };
        shadow.Position = new Vector3(0f, 0.03f, 0f);
        shadow.MaterialOverride = new StandardMaterial3D
        {
            AlbedoColor = new Color(0f, 0f, 0f, 0.35f),
            Transparency = BaseMaterial3D.TransparencyEnum.Alpha,
            ShadingMode = BaseMaterial3D.ShadingModeEnum.Unshaded,
        };
    }

    public override void _Process(double delta)
    {
        var depth = GlobalPosition.X + GlobalPosition.Z;
        SortingOffset = depth;
        RenderPriority = Mathf.Clamp((int)(depth * 8f), -100, 100);
    }
}
