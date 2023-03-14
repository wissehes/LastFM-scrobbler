//
//  Sequence+Async.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 13/03/2023.
//

import Foundation
extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
}
