using System.Text.RegularExpressions;

namespace Aether.Architecture.Tests;

internal static class SecretScanner
{
    private static readonly Regex Assignment = new(
        @"(?:^|[^A-Za-z0-9_])(password|passwd|secret|api[_-]?key|access[_-]?key|client[_-]?secret|private[_-]?key|token)\s*[:=]\s*[""']?([^""'\s#,}]+)",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);

    private static readonly Regex AwsAccessKey = new(
        @"\bAKIA[0-9A-Z]{16}\b",
        RegexOptions.CultureInvariant | RegexOptions.Compiled);

    public static bool ContainsSecret(string content)
    {
        if (content.Contains("-----BEGIN ", StringComparison.Ordinal)
            && content.Contains("PRIVATE KEY-----", StringComparison.Ordinal))
        {
            return true;
        }

        if (AwsAccessKey.IsMatch(content))
        {
            return true;
        }

        foreach (Match match in Assignment.Matches(content))
        {
            if (!IsPlaceholder(match.Groups[2].Value.Trim()))
            {
                return true;
            }
        }

        return false;
    }

    public static IReadOnlyList<string> ScanRepository(string root)
    {
        var hits = new List<string>();
        foreach (var path in Directory.EnumerateFiles(root, "*", SearchOption.AllDirectories))
        {
            if (IsSkipped(root, path) || !IsTextFile(path))
            {
                continue;
            }

            if (ContainsSecret(File.ReadAllText(path)))
            {
                hits.Add(Path.GetRelativePath(root, path));
            }
        }

        return hits;
    }

    private static bool IsPlaceholder(string value)
    {
        if (value.Length == 0)
        {
            return true;
        }

        if (value.Contains('<') || value.Contains('>') || value.Contains('$'))
        {
            return true;
        }

        return value.Equals("null", StringComparison.OrdinalIgnoreCase)
            || value.Equals("false", StringComparison.OrdinalIgnoreCase)
            || value.Equals("true", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsSkipped(string root, string path)
    {
        var relative = Path.GetRelativePath(root, path);
        var parts = relative.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        if (parts.Any(static part => part is "bin" or "obj" or ".godot" or ".git" or ".vs" or "TestResults"))
        {
            return true;
        }

        return relative.Replace('\\', '/').StartsWith("tests/", StringComparison.Ordinal);
    }

    private static bool IsTextFile(string path)
    {
        var name = Path.GetFileName(path);
        if (name is "project.godot" or "NuGet.Config" or "global.json" or ".env.example" or "VERSIONS"
            or ".gitignore" or ".editorconfig" or ".gitattributes")
        {
            return true;
        }

        return Path.GetExtension(path).ToLowerInvariant() is
            ".json" or ".md" or ".txt" or ".yml" or ".yaml" or ".ps1" or ".cs" or ".props" or ".targets"
            or ".svg" or ".tscn" or ".toml" or ".config" or ".sln" or ".cfg" or ".ini" or ".example" or ".sh";
    }
}
