using System.Text.Json;

namespace Aether.Architecture.Tests;

public class LayoutTests
{
    [Fact]
    public void RequiredPathsExist()
    {
        string[] required =
        [
            "README.md",
            "AetherOnline.sln",
            "global.json",
            "Directory.Build.props",
            "NuGet.Config",
            "VERSIONS",
            ".gitignore",
            ".editorconfig",
            ".env.example",
            "client/AetherClient/project.godot",
            "client/AetherClient/AetherClient.csproj",
            "client/AetherClient/scenes/Main.tscn",
            "client/AetherClient/scenes/Main.cs",
            "server/AetherServer/project.godot",
            "server/AetherServer/AetherServer.csproj",
            "server/AetherServer/scenes/Main.tscn",
            "server/AetherServer/scenes/Main.cs",
            "shared/Aether.GameRules/Aether.GameRules.csproj",
            "shared/Aether.Contracts/Aether.Contracts.csproj",
            "shared/Aether.GameData/Aether.GameData.csproj",
            "data/README.md",
            "database/migrations/README.md",
            "docs/GDD.md",
            "docs/TECHNICAL_ARCHITECTURE.md",
            "docs/NETWORK_PROTOCOL.md",
            "docs/DATABASE_SCHEMA.md",
            "docs/DEVELOPMENT_ROADMAP.md",
            "docs/DECISIONS.md",
            "scripts/bootstrap.ps1",
            "scripts/build.ps1",
            "scripts/test.ps1",
            "scripts/run.sh",
            "config/client.example.json",
            "config/server.example.json",
            "tools/README.md",
            "infrastructure/README.md",
        ];

        var missing = required.Where(relative => !File.Exists(Path.Combine(RepoPaths.Root, relative.Replace('/', Path.DirectorySeparatorChar)))).ToArray();
        Assert.True(missing.Length == 0, "Missing: " + string.Join(", ", missing));
    }

    [Fact]
    public void ServerIsMarkedHeadlessAndClientIsNot()
    {
        var server = File.ReadAllText(Path.Combine(RepoPaths.Root, "server", "AetherServer", "project.godot"));
        var client = File.ReadAllText(Path.Combine(RepoPaths.Root, "client", "AetherClient", "project.godot"));
        var readme = File.ReadAllText(Path.Combine(RepoPaths.Root, "README.md"));

        Assert.Contains("role=\"dedicated-server\"", server, StringComparison.Ordinal);
        Assert.Contains("headless=true", server, StringComparison.Ordinal);
        Assert.Contains("role=\"client\"", client, StringComparison.Ordinal);
        Assert.Contains("headless=false", client, StringComparison.Ordinal);
        Assert.Contains("--headless", readme, StringComparison.Ordinal);
        Assert.Contains("4.5.2", readme, StringComparison.Ordinal);
        Assert.Contains("8.0.426", readme, StringComparison.Ordinal);
    }

    [Fact]
    public void VersionPinsAgree()
    {
        var versions = File.ReadAllText(Path.Combine(RepoPaths.Root, "VERSIONS"));
        using var global = JsonDocument.Parse(File.ReadAllText(Path.Combine(RepoPaths.Root, "global.json")));
        var sdk = global.RootElement.GetProperty("sdk");

        Assert.Equal("8.0.426", sdk.GetProperty("version").GetString());
        Assert.Equal("disable", sdk.GetProperty("rollForward").GetString());
        Assert.Contains("dotnet_sdk=8.0.426", versions, StringComparison.Ordinal);
        Assert.Contains("dotnet_runtime=8.0.32", versions, StringComparison.Ordinal);
        Assert.Contains("godot_version=4.5.2", versions, StringComparison.Ordinal);
        Assert.Contains("godot_net_sdk=4.5.2", versions, StringComparison.Ordinal);
        Assert.Contains("target_framework=net8.0", versions, StringComparison.Ordinal);

        var client = File.ReadAllText(Path.Combine(RepoPaths.Root, "client", "AetherClient", "AetherClient.csproj"));
        var server = File.ReadAllText(Path.Combine(RepoPaths.Root, "server", "AetherServer", "AetherServer.csproj"));
        var tests = File.ReadAllText(Path.Combine(RepoPaths.Root, "tests", "Aether.Architecture.Tests", "Aether.Architecture.Tests.csproj"));
        Assert.Contains("Sdk=\"Godot.NET.Sdk/4.5.2\"", client, StringComparison.Ordinal);
        Assert.Contains("Sdk=\"Godot.NET.Sdk/4.5.2\"", server, StringComparison.Ordinal);
        Assert.Contains("Version=\"2.9.3\"", tests, StringComparison.Ordinal);
        Assert.Contains("Version=\"2.8.2\"", tests, StringComparison.Ordinal);
        Assert.Contains("Version=\"17.14.1\"", tests, StringComparison.Ordinal);
    }

    [Fact]
    public void GitignoreCoversBuildOutputs()
    {
        var ignore = File.ReadAllText(Path.Combine(RepoPaths.Root, ".gitignore"));
        Assert.Contains("bin/", ignore, StringComparison.Ordinal);
        Assert.Contains("obj/", ignore, StringComparison.Ordinal);
        Assert.Contains(".godot/", ignore, StringComparison.Ordinal);
        Assert.Contains(".env", ignore, StringComparison.Ordinal);
    }

    [Fact]
    public void ProductionProjectsDoNotOpenAMultiplayerPeer()
    {
        var forbidden = new[] { "ENetMultiplayerPeer", "MultiplayerPeer", "PacketPeer" };
        foreach (var relative in new[] { "client", "server", "shared" })
        {
            var directory = Path.Combine(RepoPaths.Root, relative);
            foreach (var path in Directory.EnumerateFiles(directory, "*.*", SearchOption.AllDirectories))
            {
                if (path.Contains($"{Path.DirectorySeparatorChar}bin{Path.DirectorySeparatorChar}", StringComparison.Ordinal)
                    || path.Contains($"{Path.DirectorySeparatorChar}obj{Path.DirectorySeparatorChar}", StringComparison.Ordinal)
                    || path.Contains($"{Path.DirectorySeparatorChar}.godot{Path.DirectorySeparatorChar}", StringComparison.Ordinal))
                {
                    continue;
                }

                var extension = Path.GetExtension(path);
                if (extension is not ".cs" and not ".tscn" and not ".godot")
                {
                    continue;
                }

                var text = File.ReadAllText(path);
                foreach (var token in forbidden)
                {
                    Assert.DoesNotContain(token, text, StringComparison.Ordinal);
                }
            }
        }
    }
}
