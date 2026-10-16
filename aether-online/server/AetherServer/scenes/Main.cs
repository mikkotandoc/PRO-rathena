using Aether.Contracts;
using Aether.GameData;
using Aether.GameRules;
using Godot;

namespace Aether.Server;

public partial class Main : Node
{
    public override void _Ready()
    {
        var level = ReadLogLevel();
        var database = DatabasePresence();
        GD.Print($"[{level}] AetherServer boot role=dedicated-server headless=true protocol={ProtocolVersion.Major}.{ProtocolVersion.Minor} map={PlaceholderContent.HavenMap.Id.Value} database={database} rules={EmptyRuleCatalog.Instance.Modules.Count}");
    }

    private static string ReadLogLevel()
    {
        var level = System.Environment.GetEnvironmentVariable("AETHER_LOG_LEVEL");
        return string.IsNullOrWhiteSpace(level) ? "Information" : level;
    }

    private static string DatabasePresence()
    {
        var connection = System.Environment.GetEnvironmentVariable("AETHER_DB_CONNECTION_STRING");
        return string.IsNullOrEmpty(connection) ? "unset" : "set";
    }
}
