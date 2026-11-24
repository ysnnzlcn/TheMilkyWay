//
//  AppState.swift
//  TheMilkyWay
//

import ComposableArchitecture
import ExploreBase

/// The root reducer. Explore only for now; the tab bar with Favorites comes with Favorites.
@Reducer
struct AppState {

    @ObservableState
    struct State: Equatable {
        var explore = ExploreCore.State()
    }

    enum Action: Equatable {
        case explore(ExploreCore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.explore, action: \.explore) {
            ExploreCore()
        }
    }
}
