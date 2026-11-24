//
//  AppError+Strings.swift
//  CoreUI
//

import Core

public extension AppError {

    var message: String {
        switch self {
        case .api(.offline):
            "You appear to be offline."
        case .api(.timeout):
            "The request took too long."
        case .api, .unexpected:
            "Something went wrong. Please try again."
        }
    }
}
