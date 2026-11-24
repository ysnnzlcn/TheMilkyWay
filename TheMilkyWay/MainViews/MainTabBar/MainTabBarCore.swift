//
//  MainTabBarCore.swift
//  TheMilkyWay
//

import ComposableArchitecture
import ExploreBase
import FavoritesBase

/// The two tabs and which one is open. Tapping the open tab again takes it back to its first screen.
@Reducer
struct MainTabBarCore {

    enum Tab: Hashable, Sendable {
        case explore, favorites
    }

    @ObservableState
    struct State: Equatable {
        var currentTab: Tab = .explore
        var explore = ExploreCore.State()
        var favorites = FavoritesCore.State()
    }

    enum Action: Equatable {
        case onTabSelected(Tab)
        case explore(ExploreCore.Action)
        case favorites(FavoritesCore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.explore, action: \.explore) {
            ExploreCore()
        }
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesCore()
        }
        Reduce { state, action in
            switch action {
            case let .onTabSelected(tab):
                guard tab == state.currentTab else {
                    state.currentTab = tab
                    return .none
                }
                switch tab {
                case .explore: return .send(.explore(.popToRoot))
                case .favorites: return .send(.favorites(.popToRoot))
                }

            case .explore, .favorites:
                return .none
            }
        }
    }
}
