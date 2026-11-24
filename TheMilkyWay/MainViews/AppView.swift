//
//  AppView.swift
//  TheMilkyWay
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {

    let store: StoreOf<AppState>

    var body: some View {
        MainTabBarView(store: store.scope(state: \.mainTabBar, action: \.mainTabBar))
    }
}
