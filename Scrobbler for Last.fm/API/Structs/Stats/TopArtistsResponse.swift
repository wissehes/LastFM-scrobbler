//
//  TopArtistsResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 01/02/2023.
//

import Foundation

// MARK: - LFMTopArtistsResponse
struct LFMTopArtistsResponse: Codable {
    let topartists: TopArtists
}

// MARK: - Topartists
struct TopArtists: Codable {
    let artists: [TopArtist]
    let attr: TopartistsAttributes

    enum CodingKeys: String, CodingKey {
        case artists = "artist"
        case attr = "@attr"
    }
}

// MARK: - TopArtist
struct TopArtist: Codable, Artist {
    let streamable: String
    let image: [LFMImage]
    let mbid: String
    let url: URL
    let playcount: String
    let attr: ArtistAttributes
    let name: String
    
    var id: String {
        return mbid + playcount + name
    }
    
    var playcountInt: Int? {
        Int(playcount)
    }
    
    var scrobbles: String {
        if let int = playcountInt {
            return int.formatted(.number)
        } else {
            return playcount
        }
    }

    enum CodingKeys: String, CodingKey {
        case streamable, image, mbid, url, playcount
        case attr = "@attr"
        case name
    }
}

// MARK: - ArtistAttributes
struct ArtistAttributes: Codable {
    let rank: String
}

// MARK: - TopartistsAttributes
struct TopartistsAttributes: Codable {
    let user, totalPages, page, perPage: String
    let total: String
}
