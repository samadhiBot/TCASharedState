import Combine
import Dependencies
import DependenciesMacros

@DependencyClient
struct PlayerClient {
    var update: @Sendable (_ player: Player) -> Void
    var updates: @Sendable () throws -> AsyncStream<Player>
}

extension PlayerClient: DependencyKey {
    static var liveValue: PlayerClient {
        let subject = PassthroughSubject<Player, Never>()

        return PlayerClient(
            update: { subject.send($0) },
            updates: {
                AsyncStream { continuation in
                    let cancellable = subject.removeDuplicates().sink {
                        continuation.yield($0)
                    }
                    continuation.onTermination = { _ in
                        cancellable.cancel()
                    }
                }
            }
        )
    }

    static var testValue = liveValue
}

extension DependencyValues {
    var playerClient: PlayerClient {
        get { self[PlayerClient.self] }
        set { self[PlayerClient.self] = newValue }
    }
}
