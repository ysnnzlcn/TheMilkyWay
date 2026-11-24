//
//  DS+TextStyle.swift
//  CoreUI
//

import SwiftUI

public extension DS {

    /// The app's text styles: the system font at Dynamic Type sizes, so text follows the person's text size.
    /// A custom font later changes only this type.
    enum TextStyle: CaseIterable, Sendable {
        case largeTitle
        case title
        case headline
        case body
        case subhead
        case footnote
        case caption

        public var font: Font {
            switch self {
            case .largeTitle: .system(.largeTitle, weight: .bold)
            case .title: .system(.title2, weight: .bold)
            case .headline: .system(.headline, weight: .semibold)
            case .body: .system(.body)
            case .subhead: .system(.subheadline)
            case .footnote: .system(.footnote)
            case .caption: .system(.caption)
            }
        }
    }
}

public extension View {

    /// Sets a design text style. Use it instead of `.font(...)`.
    func textStyle(_ style: DS.TextStyle) -> some View {
        font(style.font)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
        ForEach(DS.TextStyle.allCases, id: \.self) { style in
            Text("Pillars of Creation \(String(describing: style))")
                .textStyle(style)
        }
    }
    .padding()
}
