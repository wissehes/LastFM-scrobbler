//
//  LovedTracksResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import Foundation

// MARK: - LFMLovedTracksResponse
struct LFMLovedTracksResponse: Codable {
    let lovedtracks: LovedTracks
}

// MARK: - Lovedtracks
struct LovedTracks: Codable {
    let tracks: [LovedTrack]
    let attr: LovedTracksAttr

    enum CodingKeys: String, CodingKey {
        case tracks = "track"
        case attr = "@attr"
    }
}

// MARK: - LovedTracksAttr
struct LovedTracksAttr: Codable {
    let user, totalPages, page, perPage: String
    let total: String
}

// MARK: - Track
struct LovedTrack: Codable, Track {
    let artistObj: SimpleArtist
    let date: DateClass?
    let mbid: String
    let url: URL
    let name: String
    let image: [LFMImage]
//    let streamable: Streamable
    
    var artist: String {
        return self.artistObj.name
    }
    
    var actualDate: Date? {
        guard let date = date else { return nil }
        guard let interval = TimeInterval(date.uts) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
    
    var id: String {
        if let date = actualDate {
            return mbid + date.formatted() + name + artist
        } else {
            return mbid + name + artist
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case artistObj = "artist"
        case date
        case mbid
        case url
        case name
        case image
    }
    
}

//// MARK: - Streamable
//struct Streamable: Codable {
//    let fulltrack, text: String
//
//    enum CodingKeys: String, CodingKey {
//        case fulltrack
//        case text = "#text"
//    }
//}
