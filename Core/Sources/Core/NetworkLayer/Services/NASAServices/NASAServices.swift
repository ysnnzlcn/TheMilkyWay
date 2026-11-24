//
//  NASAServices.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public protocol NASAServices: Sendable {

    func searchImages() async -> Result<NASAImageResponse, AppError>
}
