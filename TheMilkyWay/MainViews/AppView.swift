//
//  AppView.swift
//  TheMilkyWay
//

import ComposableArchitecture
import ExploreBase
import SwiftUI

struct AppView: View {

    let store: StoreOf<AppState>

    var body: some View {
        ExploreView(store: store.scope(state: \.explore, action: \.explore))
    }
}
