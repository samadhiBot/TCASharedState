import ComposableArchitecture
import SwiftUI

@Reducer
struct ParentFeature: Reducer {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var player = Player()
    }

    enum Action: Equatable {
        case bumpScoreButtonTapped
        case gotoChildButtonTapped
        case path(StackAction<Path.State, Path.Action>)
        case playerUpdated(Player)
        case viewAppeared
    }

    @Reducer
    struct Path: Reducer {
        @ObservableState
        enum State: Equatable {
            case child(ChildFeature.State)
            case grandChild(GrandChildFeature.State)
        }

        enum Action: Equatable {
            case child(ChildFeature.Action)
            case grandChild(GrandChildFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: \.child, action: \.child) {
                ChildFeature()
            }
            Scope(state: \.grandChild, action: \.grandChild) {
                GrandChildFeature()
            }
        }
    }

    @Dependency(\.playerClient) var playerClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bumpScoreButtonTapped:
                state.player.bumpScore()
                return .none
            case .gotoChildButtonTapped:
                state.path.append(
                    .child(ChildFeature.State(player: state.player))
                )
                return .none
            case .path(.element(id: _, action: .child(.delegate(.showGrandChildButtonTapped)))):
                state.path.append(
                    .grandChild(GrandChildFeature.State(player: state.player))
                )
                return .none
            case .path:
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
        .forEach(\.path, action: \.path) { Path() }
    }
}

struct ParentView: View {
    @State var store: StoreOf<ParentFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                Text("Name: \(store.player.name)")
                Text("Score: \(store.player.score)")
                Button("Bump Score") {
                    store.send(.bumpScoreButtonTapped)
                }
                Button("Go to child") {
                    store.send(.gotoChildButtonTapped)
                }
            }
        } destination: { store in
            switch store.state {
            case .child:
                if let store = store.scope(state: \.child, action: \.child) {
                    ChildView(store: store)
                }
            case .grandChild:
                if let store = store.scope(state: \.grandChild, action: \.grandChild) {
                    GrandChildView(store: store)
                }
            }
        }
        .navigationTitle("Parent View")
        .task {
            store.send(.viewAppeared)
        }
    }
}

struct ParentViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ParentView(
                store: Store(
                    initialState: ParentFeature.State()
                ) {
                    ParentFeature()
                }
            )
        }
    }
}
