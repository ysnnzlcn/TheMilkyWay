//
//  Image+SystemImage.swift
//  CoreUI
//

import CoreAssets
import SwiftUI

public extension Image {

    /// An SF Symbol from `SystemImage`.
    init(systemImage: SystemImage) {
        self.init(systemName: systemImage.rawValue)
    }
}

public extension Label where Title == Text, Icon == Image {

    init(_ title: String, systemImage: SystemImage) {
        self.init(title, systemImage: systemImage.rawValue)
    }
}
