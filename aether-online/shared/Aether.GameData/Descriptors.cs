namespace Aether.GameData;

public sealed record MapDescriptor(ContentId Id, string DisplayName, bool Placeholder);

public sealed record AppearanceDescriptor(ContentId Id, string DisplayName, bool Placeholder);
