using System.Text.Json;

namespace Aether.Architecture.Tests;

public class ConfigurationTests
{
    [Fact]
    public void SamplesContainNoSecrets()
    {
        Assert.True(SecretScanner.ContainsSecret("password=hunter2"));
        Assert.True(SecretScanner.ContainsSecret("-----BEGIN OPENSSH PRIVATE KEY-----\nabc\n-----END OPENSSH PRIVATE KEY-----"));
        Assert.False(SecretScanner.ContainsSecret("Password=<from-secret-store>"));
        Assert.False(SecretScanner.ContainsSecret("\"connectionStringEnv\": \"AETHER_DB_CONNECTION_STRING\""));

        var hits = SecretScanner.ScanRepository(RepoPaths.Root);
        Assert.True(hits.Count == 0, "Secret-like content in: " + string.Join(", ", hits));
    }

    [Fact]
    public void ClientSampleHasNoDatabaseAndServerSampleUsesAnEnvironmentVariable()
    {
        using var client = JsonDocument.Parse(File.ReadAllText(Path.Combine(RepoPaths.Root, "config", "client.example.json")));
        using var server = JsonDocument.Parse(File.ReadAllText(Path.Combine(RepoPaths.Root, "config", "server.example.json")));

        Assert.False(client.RootElement.TryGetProperty("database", out _));
        Assert.Equal("Information", client.RootElement.GetProperty("logging").GetProperty("minimumLevel").GetString());

        var database = server.RootElement.GetProperty("database");
        Assert.Equal("postgresql", database.GetProperty("provider").GetString());
        Assert.False(database.GetProperty("enabled").GetBoolean());
        Assert.Equal("AETHER_DB_CONNECTION_STRING", database.GetProperty("connectionStringEnv").GetString());
        Assert.False(database.TryGetProperty("connectionString", out _));
        Assert.False(database.TryGetProperty("password", out _));
    }

    [Fact]
    public void ServerLogLineDoesNotPrintTheConnectionString()
    {
        var source = File.ReadAllLines(Path.Combine(RepoPaths.Root, "server", "AetherServer", "scenes", "Main.cs"));
        var client = File.ReadAllText(Path.Combine(RepoPaths.Root, "client", "AetherClient", "scenes", "Main.cs"));
        Assert.DoesNotContain("AETHER_DB_CONNECTION_STRING", client, StringComparison.Ordinal);

        foreach (var line in source)
        {
            if (!line.Contains("GD.Print", StringComparison.Ordinal))
            {
                continue;
            }

            Assert.DoesNotContain("AETHER_DB_CONNECTION_STRING", line, StringComparison.Ordinal);
            Assert.DoesNotContain("GetEnvironmentVariable", line, StringComparison.Ordinal);
        }
    }
}
