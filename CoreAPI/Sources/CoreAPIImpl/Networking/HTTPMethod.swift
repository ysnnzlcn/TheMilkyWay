//
//  HTTPMethod.swift
//  CoreAPIImpl
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

enum HTTPMethod: String, Sendable {

    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}
