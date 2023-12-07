import ComposableArchitecture
import SwiftUI

@Reducer
struct GrandChildFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var player: Player
    }

    enum Action: Equatable {
        case bumpAndChangeButtonTapped
    }

    @Dependency(\.playerClient) var playerClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bumpAndChangeButtonTapped:
                state.player.bumpScore()
                state.player.changeName(to: state.player.score)
                playerClient.update(state.player)
                return .none
            }
        }
    }
}

struct GrandChildView: View {
    @State var store: StoreOf<GrandChildFeature>

    var body: some View {
        List {
            Text("Player name: \(store.player.name)")
            Text("Player score: \(store.player.score)")
            Button("Bump score & Change name") {
                store.send(.bumpAndChangeButtonTapped)
            }
        }
        .navigationTitle("GrandChild View")
    }
}

struct GrandChildViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GrandChildView(
                store: Store(
                    initialState: GrandChildFeature.State(
                        player: Player()
                    )
                ) {
                    GrandChildFeature()
                }
            )
        }
    }
}
