namespace Aether.Architecture.Tests;

public class ProjectReferenceTests
{
    [Fact]
    public void ProjectGraphHasNoCyclesAndObeysTheSplit()
    {
        var graph = ProjectGraph.Load(RepoPaths.Root);
        var cycles = ProjectGraph.FindCycles(graph);
        Assert.True(cycles.Count == 0, string.Join("; ", cycles));

        Assert.Empty(graph["Aether.GameData"]);
        Assert.Empty(graph["Aether.Contracts"]);
        Assert.Equal(
            new[] { "Aether.Contracts", "Aether.GameData" },
            graph["Aether.GameRules"].OrderBy(name => name, StringComparer.Ordinal).ToArray());

        Assert.DoesNotContain("AetherServer", graph["AetherClient"]);
        Assert.DoesNotContain("AetherClient", graph["AetherServer"]);
        Assert.DoesNotContain("AetherClient", graph["Aether.Architecture.Tests"]);
        Assert.DoesNotContain("AetherServer", graph["Aether.Architecture.Tests"]);

        foreach (var shared in new[] { "Aether.GameData", "Aether.Contracts", "Aether.GameRules" })
        {
            var csproj = File.ReadAllText(FindProject(shared));
            Assert.Contains("Sdk=\"Microsoft.NET.Sdk\"", csproj, StringComparison.Ordinal);
            Assert.DoesNotContain("Godot.NET.Sdk", csproj, StringComparison.Ordinal);
            Assert.DoesNotContain("AetherClient", graph[shared]);
            Assert.DoesNotContain("AetherServer", graph[shared]);
        }
    }

    private static string FindProject(string assemblyName)
    {
        return Directory.EnumerateFiles(RepoPaths.Root, assemblyName + ".csproj", SearchOption.AllDirectories)
            .Single(path => !path.Contains($"{Path.DirectorySeparatorChar}bin{Path.DirectorySeparatorChar}", StringComparison.Ordinal));
    }
}
