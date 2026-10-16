using Aether.Contracts;
using Aether.GameData;

namespace Aether.GameRules;

public interface IContentLookup
{
    MapDescriptor? FindMap(ContentId id);
}

public interface IMessageKindFilter
{
    bool Allows(MessageKind kind);
}
