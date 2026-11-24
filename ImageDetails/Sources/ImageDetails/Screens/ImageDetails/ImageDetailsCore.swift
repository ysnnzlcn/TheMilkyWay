//
//  ImageDetailsCore.swift
//  ImageDetails
//

import ComposableArchitecture
import CoreBase

/// One image: large picture, title, details and description. Pushed from Explore (and later Favorites); no request,
/// it shows the image it was opened with.
@Reducer
public struct ImageDetailsCore: Sendable {

    public init() { }

    @ObservableState
    public struct State: Equatable, Sendable {
        // Information State
        let image: NASAImageDTO

        public init(image: NASAImageDTO) {
            self.image = image
        }
    }

    public enum Action: Equatable, Sendable { }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
