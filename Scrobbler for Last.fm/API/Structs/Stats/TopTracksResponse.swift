//
//  TopTracksResponse.swift
//  Scrobbler for Last.fm
//
//  Created by Wisse Hes on 02/02/2023.
//

import Foundation
// MARK: - LFMTopTracks
struct LFMTopTracksResponse: Codable {
    let toptracks: TopTracks
}

// MARK: - Toptracks
struct TopTracks: Codable {
    let tracks: [TopTrack]
    let attr: ToptracksAttr

    enum CodingKeys: String, CodingKey {
        case tracks = "track"
        case attr = "@attr"
    }
}

// MARK: - ToptracksAttr
struct ToptracksAttr: Codable {
    let user, totalPages, page, perPage: String
    let total: String
}

// MARK: - TopTrack
struct TopTrack: Codable, Equatable, Track {
    let mbid, name: String
    let image: [LFMImage]
    let artistObj: TopTrackArtist
    let url: URL
    let duration: String
    let attr: TrackAttr
    let playcount: String
    
    var artist: String {
        return self.artistObj.name
    }
    
    var id: String {
        return mbid + name + artist
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
        case mbid, name, image, url, duration
        case artistObj = "artist"
        case attr = "@attr"
        case playcount
    }
    
    // MARK: - Artist
    struct TopTrackArtist: Codable, Artist {
        let url: String
        let name, mbid: String
    }
    
    static func == (lhs: TopTrack, rhs: TopTrack) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - TrackAttr
struct TrackAttr: Codable {
    let rank: String
}
