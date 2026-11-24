//
//  AppEnvironment.swift
//  CoreBase
//

import Foundation

/// Which build this is, from its build configuration. The app target reads it (`AppEnvironment.current`).
/// Which API a build talks to is decided separately, in the app's `AppInterface`.
public enum AppEnvironment: Sendable {

    case debug, release
}
