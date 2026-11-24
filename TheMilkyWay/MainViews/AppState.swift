//
//  AppState.swift
//  TheMilkyWay
//

import ComposableArchitecture

/// The root reducer: the tab bar.
@Reducer
struct AppState {

    @ObservableState
    struct State: Equatable {
        var mainTabBar = MainTabBarCore.State()
    }

    enum Action: Equatable {
        case mainTabBar(MainTabBarCore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.mainTabBar, action: \.mainTabBar) {
            MainTabBarCore()
        }
    }
}
