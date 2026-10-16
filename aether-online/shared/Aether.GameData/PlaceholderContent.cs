namespace Aether.GameData;

public static class PlaceholderContent
{
    public static ContentId HavenMapId { get; } = new("map.placeholder.haven");

    public static ContentId TravelerAppearanceId { get; } = new("appearance.placeholder.traveler");

    public static MapDescriptor HavenMap { get; } = new(HavenMapId, "Placeholder Haven", true);

    public static AppearanceDescriptor TravelerAppearance { get; } = new(TravelerAppearanceId, "Placeholder Traveler", true);
}
