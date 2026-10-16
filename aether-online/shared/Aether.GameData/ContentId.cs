namespace Aether.GameData;

public readonly record struct ContentId(string Value)
{
    public override string ToString() => Value;
}
