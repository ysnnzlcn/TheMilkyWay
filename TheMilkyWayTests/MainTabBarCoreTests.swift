//
//  MainTabBarCoreTests.swift
//  TheMilkyWayTests
//

import ComposableArchitecture
import CoreBase
import ExploreBase
import Testing
@testable import TheMilkyWay

@MainActor
struct MainTabBarCoreTests {

    @Test func selectingAnotherTabSwitchesToIt() async {
        let store = TestStore(initialState: MainTabBarCore.State()) { MainTabBarCore() }

        await store.send(.onTabSelected(.favorites)) { $0.currentTab = .favorites }
        await store.send(.onTabSelected(.explore)) { $0.currentTab = .explore }
    }

    @Test func tappingTheOpenTabGoesBackToItsFirstScreen() async {
        let store = TestStore(initialState: MainTabBarCore.State()) { MainTabBarCore() }

        await store.send(.onTabSelected(.explore))
        await store.receive(.explore(.popToRoot))

        await store.send(.onTabSelected(.favorites)) { $0.currentTab = .favorites }
        await store.send(.onTabSelected(.favorites))
        await store.receive(.favorites(.popToRoot))
    }
}
