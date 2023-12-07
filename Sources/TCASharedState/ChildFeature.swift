import ComposableArchitecture
import SwiftUI

@Reducer
struct ChildFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var player: Player
    }

    enum Action: Equatable {
        case bumpScoreButtonTapped
        case changeNameButtonTapped
        case delegate(Delegate)
        case playerUpdated(Player)
        case viewAppeared

        enum Delegate {
            case showGrandChildButtonTapped
        }
    }

    @Dependency(\.playerClient) var playerClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bumpScoreButtonTapped:
                state.player.bumpScore()
                playerClient.update(state.player)
                return .none
            case .changeNameButtonTapped:
                state.player.changeName(to: state.player.score)
                playerClient.update(state.player)
                return .none
            case .delegate:
                return .none
            case let .playerUpdated(player):
                state.player = player
                return .none
            case .viewAppeared:
                return .run { send in
                    for await player in try playerClient.updates() {
                        await send(.playerUpdated(player))
                    }
                }
            }
        }
    }
}

struct ChildView: View {
    @State var store: StoreOf<ChildFeature>

    var body: some View {
        List {
            Text("Player name: \(store.player.name)")
            Text("Player score: \(store.player.score)")
            Button("Bump score") {
                store.send(.bumpScoreButtonTapped)
            }
            Button("Change name") {
                store.send(.changeNameButtonTapped)
            }
            Button("Go to grandchild") {
                store.send(.delegate(.showGrandChildButtonTapped))
            }
        }
        .navigationTitle("Child View")
        .task {
            store.send(.viewAppeared)
        }
    }
}

struct ChildViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChildView(
                store: Store(
                    initialState: ChildFeature.State(
                        player: Player()
                    )
                ) {
                    ChildFeature()
                }
            )
        }
    }
}
