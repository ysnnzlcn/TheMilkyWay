//
//  DS.swift
//  CoreUI
//

import SwiftUI

/// The app's design tokens. Views use these instead of raw values. Colors are system semantic colors, so dark mode
/// and Increase Contrast work everywhere; text uses `DS.TextStyle` (`.textStyle(.headline)`), never fixed sizes.
public enum DS {

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
    }

    public enum Colors {
        public static let bg = Color(.systemBackground)
        public static let surface = Color(.secondarySystemBackground)
        public static let textPrimary = Color(.label)
        public static let textSecondary = Color(.secondaryLabel)
        public static let accent = Color.accentColor
        public static let error = Color(.systemRed)
        /// Behind an image that is loading or failed.
        public static let placeholder = Color(.secondarySystemFill)
        public static let placeholderIcon = Color(.tertiaryLabel)
        /// The toast: dark on light, light on dark.
        public static let inverseSurface = Color(.label)
        public static let onInverseSurface = Color(.systemBackground)
    }

    public enum Motion {
        public static let fast: Double = 0.2
        public static let base: Double = 0.3
        /// How long a toast stays.
        public static let toast: Duration = .seconds(4)
        public static let errorToast: Duration = .seconds(6)
    }
}
