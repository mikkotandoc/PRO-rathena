namespace Aether.GameRules;

public interface IGameRuleModule
{
    string ModuleId { get; }
}

public interface IRuleCatalog
{
    IReadOnlyList<IGameRuleModule> Modules { get; }
}

public sealed class EmptyRuleCatalog : IRuleCatalog
{
    public static EmptyRuleCatalog Instance { get; } = new();

    private EmptyRuleCatalog()
    {
    }

    public IReadOnlyList<IGameRuleModule> Modules { get; } = Array.Empty<IGameRuleModule>();
}
