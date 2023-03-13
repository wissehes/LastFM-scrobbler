//
//  ArtistInfoResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 03/02/2023.
//

import Foundation

// MARK: - LFMArtistInfoResponse
struct LFMArtistInfoResponse: Codable {
    let artist: ArtistInfo
}

// MARK: - ArtistInfo
struct ArtistInfo: Codable, Artist {
    let name: String
    let mbid: String?
    let url: URL?
    let image: [LFMImage]
    let streamable, ontour: String
    let stats: ArtistStats
    let similar: Similar
    let tags: Tags
    let bio: ArtistBio
}

// MARK: - ArtistBio
struct ArtistBio: Codable {
    let links: Links
    let published, summary, content: String
}

// MARK: - Links
struct Links: Codable {
    let link: LFMLink
}

// MARK: - LFMLink
struct LFMLink: Codable {
    let text, rel: String
    let href: String

    enum CodingKeys: String, CodingKey {
        case text = "#text"
        case rel, href
    }
}

// MARK: - Similar
struct Similar: Codable {
    let artist: [SimilarArtist]
}

// MARK: - SimilarArtist
struct SimilarArtist: Codable, Artist {
    let name: String
    let url: String
    let image: [LFMImage]
}

// MARK: - ArtistStats
struct ArtistStats: Codable {
    let listeners, playcount, userplaycount: String
    
    var listenersInt: Int? {
        return Int(listeners)
    }
    
    var playcountInt: Int? {
        return Int(playcount)
    }
    
    var userplaycountInt: Int? {
        return Int(userplaycount)
    }
}

// MARK: - Tags
struct Tags: Codable {
    let tag: [Tag]
}

// MARK: - Tag
struct Tag: Codable {
    let name: String
    let url: URL?
}
