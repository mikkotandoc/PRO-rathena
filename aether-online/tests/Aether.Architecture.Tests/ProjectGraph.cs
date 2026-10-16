using System.Text.RegularExpressions;

namespace Aether.Architecture.Tests;

internal static class ProjectGraph
{
    private static readonly Regex ProjectReferenceRegex = new(
        @"ProjectReference\s+Include\s*=\s*""([^""]+)""",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);

    public static IReadOnlyDictionary<string, IReadOnlyList<string>> Load(string root)
    {
        var graph = new Dictionary<string, IReadOnlyList<string>>(StringComparer.OrdinalIgnoreCase);
        foreach (var project in Directory.EnumerateFiles(root, "*.csproj", SearchOption.AllDirectories))
        {
            if (IsSkipped(root, project))
            {
                continue;
            }

            var references = new List<string>();
            foreach (Match match in ProjectReferenceRegex.Matches(File.ReadAllText(project)))
            {
                var include = match.Groups[1].Value.Replace('\\', '/');
                references.Add(Path.GetFileNameWithoutExtension(include));
            }

            graph[Path.GetFileNameWithoutExtension(project)] = references;
        }

        return graph;
    }

    public static IReadOnlyList<string> FindCycles(IReadOnlyDictionary<string, IReadOnlyList<string>> graph)
    {
        var state = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        var cycles = new List<string>();
        foreach (var name in graph.Keys)
        {
            Visit(name, graph, state, new Stack<string>(), cycles);
        }

        return cycles;
    }

    private static void Visit(
        string name,
        IReadOnlyDictionary<string, IReadOnlyList<string>> graph,
        Dictionary<string, int> state,
        Stack<string> stack,
        List<string> cycles)
    {
        if (state.TryGetValue(name, out var seen))
        {
            if (seen == 1)
            {
                var chain = stack.Reverse().ToList();
                chain.Add(name);
                cycles.Add(string.Join(" -> ", chain));
            }

            return;
        }

        state[name] = 1;
        stack.Push(name);
        if (graph.TryGetValue(name, out var references))
        {
            foreach (var next in references)
            {
                Visit(next, graph, state, stack, cycles);
            }
        }

        stack.Pop();
        state[name] = 2;
    }

    private static bool IsSkipped(string root, string path)
    {
        var relative = Path.GetRelativePath(root, path);
        var parts = relative.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        return parts.Any(static part => part is "bin" or "obj" or ".godot" or ".git");
    }
}
