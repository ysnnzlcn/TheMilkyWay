//
//  MainTabBarView.swift
//  TheMilkyWay
//

import ComposableArchitecture
import CoreAssets
import CoreUI
import ExploreBase
import FavoritesBase
import SwiftUI

struct MainTabBarView: View {

    @Bindable var store: StoreOf<MainTabBarCore>

    var body: some View {
        TabView(selection: $store.currentTab.sending(\.onTabSelected)) {
            Tab(value: .explore) {
                ExploreView(store: store.scope(state: \.explore, action: \.explore))
            } label: {
                Label(L10n.Core.tabsExplore, systemImage: .sparkles)
            }
            Tab(value: .favorites) {
                FavoritesView(store: store.scope(state: \.favorites, action: \.favorites))
            } label: {
                Label(L10n.Core.tabsFavorites, systemImage: .heart)
            }
        }
    }
}
