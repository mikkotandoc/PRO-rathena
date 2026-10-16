using System.Reflection;
using Aether.Contracts;
using Aether.GameData;
using Aether.GameRules;

namespace Aether.Architecture.Tests;

public class SharedTypeTests
{
    [Fact]
    public void ContractTypesExistAndCarryNoTransport()
    {
        var hello = new HelloMessage("dev", ProtocolVersion.Major, ProtocolVersion.Minor);
        var ack = new HelloAckMessage(ProtocolVersion.Major, ProtocolVersion.Minor, "dev");
        var disconnect = new DisconnectNotice(DisconnectReasons.ClientRequested);

        Assert.Equal(0, ProtocolVersion.Major);
        Assert.Equal(1, ProtocolVersion.Minor);
        Assert.Equal("aether.session", ProtocolVersion.Name);
        Assert.Equal(MessageKind.Hello, hello.Kind);
        Assert.Equal(MessageKind.HelloAck, ack.Kind);
        Assert.Equal(MessageKind.Disconnect, disconnect.Kind);
        Assert.Equal("protocol_mismatch", DisconnectReasons.ProtocolMismatch);
    }

    [Fact]
    public void PlaceholderContentMatchesDescriptorFiles()
    {
        Assert.Equal("map.placeholder.haven", PlaceholderContent.HavenMap.Id.Value);
        Assert.Equal("Placeholder Haven", PlaceholderContent.HavenMap.DisplayName);
        Assert.True(PlaceholderContent.HavenMap.Placeholder);
        Assert.Equal("appearance.placeholder.traveler", PlaceholderContent.TravelerAppearance.Id.Value);
        Assert.True(PlaceholderContent.TravelerAppearance.Placeholder);

        AssertDescriptor(
            Path.Combine(RepoPaths.Root, "data", "maps", "placeholder-haven.json"),
            PlaceholderContent.HavenMap.Id.Value,
            PlaceholderContent.HavenMap.DisplayName);
        AssertDescriptor(
            Path.Combine(RepoPaths.Root, "data", "appearances", "placeholder-traveler.json"),
            PlaceholderContent.TravelerAppearance.Id.Value,
            PlaceholderContent.TravelerAppearance.DisplayName);
    }

    [Fact]
    public void RuleModulesAreInterfacesWithAnEmptyCatalog()
    {
        Assert.True(typeof(IGameRuleModule).IsInterface);
        Assert.True(typeof(IRuleCatalog).IsInterface);
        Assert.True(typeof(IContentLookup).IsInterface);
        Assert.True(typeof(IMessageKindFilter).IsInterface);
        Assert.Empty(EmptyRuleCatalog.Instance.Modules);

        var implementations = typeof(IGameRuleModule).Assembly
            .GetTypes()
            .Where(type => type.IsClass && !type.IsAbstract && typeof(IGameRuleModule).IsAssignableFrom(type));
        Assert.Empty(implementations);
    }

    [Fact]
    public void SharedAssembliesDoNotReferenceGodotOrCycle()
    {
        var contractRefs = Names(typeof(HelloMessage).Assembly);
        var dataRefs = Names(typeof(MapDescriptor).Assembly);
        var ruleRefs = Names(typeof(IGameRuleModule).Assembly);

        Assert.DoesNotContain("GodotSharp", contractRefs);
        Assert.DoesNotContain("Aether.GameData", contractRefs);
        Assert.DoesNotContain("Aether.GameRules", contractRefs);
        Assert.DoesNotContain("AetherClient", contractRefs);
        Assert.DoesNotContain("AetherServer", contractRefs);

        Assert.DoesNotContain("GodotSharp", dataRefs);
        Assert.DoesNotContain("Aether.Contracts", dataRefs);
        Assert.DoesNotContain("Aether.GameRules", dataRefs);

        Assert.Contains("Aether.Contracts", ruleRefs);
        Assert.Contains("Aether.GameData", ruleRefs);
        Assert.DoesNotContain("GodotSharp", ruleRefs);
        Assert.DoesNotContain("AetherClient", ruleRefs);
        Assert.DoesNotContain("AetherServer", ruleRefs);
    }

    private static HashSet<string> Names(Assembly assembly)
    {
        return assembly.GetReferencedAssemblies()
            .Select(name => name.Name ?? string.Empty)
            .ToHashSet(StringComparer.Ordinal);
    }

    private static void AssertDescriptor(string path, string id, string displayName)
    {
        using var document = System.Text.Json.JsonDocument.Parse(File.ReadAllText(path));
        var root = document.RootElement;
        Assert.Equal(id, root.GetProperty("id").GetString());
        Assert.Equal(displayName, root.GetProperty("displayName").GetString());
        Assert.True(root.GetProperty("placeholder").GetBoolean());

        foreach (var property in root.EnumerateObject())
        {
            Assert.DoesNotContain(
                property.Name,
                new[] { "damage", "hp", "exp", "experience", "jobLevel", "attack", "defense" },
                StringComparer.OrdinalIgnoreCase);
        }
    }
}
