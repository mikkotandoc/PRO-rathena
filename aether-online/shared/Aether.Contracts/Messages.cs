namespace Aether.Contracts;

public enum MessageKind
{
    Hello = 1,
    HelloAck = 2,
    Disconnect = 3,
}

public abstract record GameMessage(MessageKind Kind);

public sealed record HelloMessage(string ClientBuild, int ProtocolMajor, int ProtocolMinor)
    : GameMessage(MessageKind.Hello);

public sealed record HelloAckMessage(int ProtocolMajor, int ProtocolMinor, string ServerBuild)
    : GameMessage(MessageKind.HelloAck);

public sealed record DisconnectNotice(string ReasonCode)
    : GameMessage(MessageKind.Disconnect);

public static class DisconnectReasons
{
    public const string ClientRequested = "client_requested";

    public const string ProtocolMismatch = "protocol_mismatch";
}
