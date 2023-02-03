//
//  GetSessionResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import Foundation

struct GetSessionResponse: Codable {
    let session: LFMSession
}

struct LFMSession: Codable {
    let name: String
    let key: String
}
